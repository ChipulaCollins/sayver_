# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Don't obfuscate Flutter native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter engine / SharedPreferences
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-dontwarn io.flutter.**
