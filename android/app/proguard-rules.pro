# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# Keep all classes for JSON serialization (critical for Tu Vi feature)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep all model classes (very important for the Tu Vi app)
-keep class **.models.** { *; }
-keep class **.data.models.** { *; }
-keep class **.entity.** { *; }
-keep class **.dto.** { *; }
-keep class **.tu_vi.** { *; }

# Keep JSON serializable generated code
-keep class **.g.dart { *; }
-keep class **.g.** { *; }

# For json_annotation/json_serializable
-keep class **.g.dart { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent stripping of methods/fields annotated with @JsonSerializable
-keepclassmembers class * {
    @*.JsonSerializable *;
}

# Keep all fields in model classes for JSON serialization
-keepclassmembers class **.data.models.** {
    <fields>;
}
-keepclassmembers class **.models.** {
    <fields>;
}

# For Dio/Retrofit if you're using
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-dontwarn okio.**
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# Keep JSON serializable classes
-keep class * implements java.io.Serializable { *; }

# Keep all model classes (adjust package name as needed)
-keep class com.physiognomy.app.ai_physiognomy.** { *; }

# Keep Gson/JSON related classes
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# For Retrofit if you're using
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Keep HTTP/Network classes
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Camera plugin
-keep class io.flutter.plugins.camera.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}