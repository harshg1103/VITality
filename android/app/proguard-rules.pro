# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase & gRPC (Firestore Requirements)
-keep class io.grpc.** { *; }
-keep class com.google.firebase.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class com.google.common.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Prevent shrinking of serialized classes
-keepattributes Signature
-keepattributes *Annotation*

# Ignore missing optional classes that cause R8 to fail the build
-dontwarn com.google.android.play.core.**
-dontwarn com.squareup.okhttp.**
-dontwarn java.lang.reflect.AnnotatedType
-dontwarn io.flutter.embedding.**
-dontwarn io.grpc.**
