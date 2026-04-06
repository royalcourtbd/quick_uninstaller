package com.amatullah.quickuninstaller

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "com.amatullah.quickuninstaller/apps"
    private val ICON_SIZE = 96

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        Thread {
                            try {
                                val apps = getInstalledApps()
                                runOnUiThread { result.success(apps) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("ERROR", e.message, null) }
                            }
                        }.start()
                    }
                    "getMemoryInfo" -> {
                        try {
                            val memInfo = getMemoryInfo()
                            result.success(memInfo)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    "uninstallApp" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            try {
                                val intent = Intent(Intent.ACTION_DELETE).apply {
                                    data = Uri.parse("package:$packageName")
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("ERROR", e.message, null)
                            }
                        } else {
                            result.error("ERROR", "Package name is required", null)
                        }
                    }
                    "isAppInstalled" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val installed = isAppInstalled(packageName)
                            result.success(installed)
                        } else {
                            result.error("ERROR", "Package name is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val packages: List<PackageInfo> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(0)
        }

        return packages.map { packageInfo ->
            val appInfo = packageInfo.applicationInfo
            val isSystemApp = appInfo != null &&
                    (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            val appName = appInfo?.let { pm.getApplicationLabel(it).toString() } ?: packageInfo.packageName
            val versionName = packageInfo.versionName ?: ""
            val appSize = getAppSize(appInfo)
            val installDate = packageInfo.firstInstallTime
            val iconBytes = appInfo?.let { getAppIconBytes(pm, it) }

            mapOf(
                "packageName" to packageInfo.packageName,
                "appName" to appName,
                "versionName" to versionName,
                "appSize" to appSize,
                "installDate" to installDate,
                "isSystemApp" to isSystemApp,
                "appIcon" to iconBytes
            )
        }
    }

    private fun getAppSize(appInfo: ApplicationInfo?): Long {
        if (appInfo == null) return 0L
        return try {
            val sourceDir = appInfo.sourceDir
            val file = File(sourceDir)
            file.length()
        } catch (e: Exception) {
            0L
        }
    }

    private fun getAppIconBytes(pm: PackageManager, appInfo: ApplicationInfo): ByteArray? {
        return try {
            val drawable: Drawable = pm.getApplicationIcon(appInfo)
            val bitmap = drawableToBitmap(drawable)
            val stream = ByteArrayOutputStream()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                bitmap.compress(Bitmap.CompressFormat.WEBP_LOSSY, 80, stream)
            } else {
                @Suppress("DEPRECATION")
                bitmap.compress(Bitmap.CompressFormat.WEBP, 80, stream)
            }
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            val src = drawable.bitmap
            if (src.width <= ICON_SIZE && src.height <= ICON_SIZE) return src
            return Bitmap.createScaledBitmap(src, ICON_SIZE, ICON_SIZE, true)
        }

        val bitmap = Bitmap.createBitmap(ICON_SIZE, ICON_SIZE, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, ICON_SIZE, ICON_SIZE)
        drawable.draw(canvas)
        return bitmap
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun getMemoryInfo(): Map<String, Long> {
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = stat.totalBytes
        val freeBytes = stat.availableBytes
        return mapOf(
            "totalBytes" to totalBytes,
            "freeBytes" to freeBytes
        )
    }
}
