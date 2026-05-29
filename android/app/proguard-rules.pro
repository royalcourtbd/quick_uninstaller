# ===================================================================
# PROGUARD / R8 RULES - Quick Uninstaller
# ===================================================================

# ===================================================================
# GENERAL ANDROID / KOTLIN
# ===================================================================
# Keep metadata used by Firebase, Kotlin/Java annotations, generic signatures,
# and Crashlytics deobfuscated stack traces.
-keepattributes Signature,*Annotation*,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable

# Honor AndroidX @Keep on generated/plugin classes while still allowing R8 to
# shrink everything else normally.
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# ===================================================================
# APP ENTRY POINT
# ===================================================================
# MainActivity is referenced from AndroidManifest.xml. Its MethodChannel handler
# is direct Kotlin code, so only the manifest entry point needs to stay stable.
-keep class com.amatullah.quickuninstaller.MainActivity { <init>(); }

# ===================================================================
# FLUTTER
# ===================================================================
# Background isolates and some Flutter plugins resolve callback information and
# registrants at runtime.
-keep class io.flutter.view.FlutterCallbackInformation { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}
-keep class * {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}
-keep class com.rmawatson.flutterisolate.** { *; }

# ===================================================================
# FIREBASE / FLUTTERFIRE
# ===================================================================
# FlutterFire registers components through manifest metadata and Firebase's
# component discovery mechanism.
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# ===================================================================
# SUPPRESS COMMON WARNINGS
# ===================================================================
# Common compile-time-only annotation warnings from Google/Firebase transitive
# dependencies.
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn com.google.j2objc.annotations.**
-dontwarn org.codehaus.mojo.animal_sniffer.**

# ===================================================================
# FLUTTER DEFERRED COMPONENTS
# ===================================================================
# Flutter references Play Core deferred-component APIs only when deferred
# components are used. This app does not declare deferred components, so these
# optional references can be ignored by R8.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
