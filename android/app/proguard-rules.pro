# Project-specific R8/ProGuard rules.
#
# Flutter's Gradle plugin already adds the default Android optimized rules and
# Flutter's own rules for release builds. This file is picked up automatically
# when it exists at android/app/proguard-rules.pro.

# Keep generic metadata used by Firebase, Kotlin/Java annotations, and generic
# signatures in Android libraries.
-keepattributes Signature,*Annotation*,InnerClasses,EnclosingMethod

# MainActivity is referenced from AndroidManifest.xml and owns the native
# MethodChannel bridge used by the Dart uninstaller data source.
-keep class com.amatullah.quickuninstaller.MainActivity { *; }

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

# FlutterFire registers components through manifest metadata and Firebase's
# component discovery mechanism.
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# Preserve native method names for libraries that cross the JNI boundary.
-keepclasseswithmembernames class * {
    native <methods>;
}

# Common compile-time-only annotation warnings from Google/Firebase transitive
# dependencies.
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn com.google.j2objc.annotations.**
-dontwarn org.codehaus.mojo.animal_sniffer.**

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
