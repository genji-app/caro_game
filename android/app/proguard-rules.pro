# =============================================================================
# ProGuard / R8 rules for S88 Sport (com.app.caro.classic2026)
#
# QUAN TRỌNG: R8 chỉ minify code Java/Kotlin trên Android side.
# Code Dart (Flutter app + tất cả package Dart như unlock_shorebird_kit,
# game_engine, sport_socket, freezed models, dio, riverpod, hive, ...) được
# Dart AOT biên dịch vào libapp.so → R8 KHÔNG đụng tới. Vì vậy KHÔNG cần
# keep rule cho freezed model, fromJson/toJson, riverpod provider, ...
#
# File này chỉ keep phần Java/Kotlin của Flutter engine + plugin Android.
# =============================================================================

# ──────────────────────────────────────────────────────────────────────────────
# Attributes (signature, generic, annotation, line-number cho stack trace)
# ──────────────────────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ──────────────────────────────────────────────────────────────────────────────
# Generic catch-all cho Flutter plugin
# Bất kỳ plugin nào extends FlutterPlugin / implements MethodCallHandler đều
# được giữ nguyên. Đây là "lưới an toàn" — sau này thêm plugin mới không cần
# update file này.
# ──────────────────────────────────────────────────────────────────────────────
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * extends io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }
-keep class * extends io.flutter.embedding.engine.plugins.service.ServiceAware { *; }
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$Registrar { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$RequestPermissionsResultListener { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$ActivityResultListener { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$NewIntentListener { *; }

# Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# JNI native methods (rive_native, jni, audioplayers...)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Enum values()/valueOf() — preserve cho Dart channel switch + serialization
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Cho phép log line số khi obfuscate (lưu mapping cho de-symbolicate)
-keepattributes SourceFile,LineNumberTable

# ──────────────────────────────────────────────────────────────────────────────
# Shorebird code push — phần lớn nằm trong libflutter.so đã patch, nhưng giữ
# namespace phòng các Java helper.
# ──────────────────────────────────────────────────────────────────────────────
-keep class dev.shorebird.** { *; }
-keep class shorebird.** { *; }
-dontwarn dev.shorebird.**
-dontwarn shorebird.**

# ──────────────────────────────────────────────────────────────────────────────
# PLUGIN CỤ THỂ (theo .flutter-plugins-dependencies)
# Liệt kê cho rõ ràng + defense-in-depth nếu generic rule trên có miss.
# ──────────────────────────────────────────────────────────────────────────────

# audioplayers_android (5.2.1) — sử dụng Media3/ExoPlayer
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**
# ExoPlayer / Media3 (audioplayers internally)
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# connectivity_plus (6.1.5)
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
-dontwarn dev.fluttercommunity.plus.connectivity.**

# device_info_plus (9.1.2)
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-dontwarn dev.fluttercommunity.plus.device_info.**

# flutter_inappwebview_android (1.1.3) — heavy native, nhiều JS bridge
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**
-dontwarn com.pichillilorenzo.flutter_inappwebview_android.**

# jni / jni_flutter — Dart FFI bridge, dùng reflection JNI
-keep class com.github.dart_lang.jni.** { *; }
-dontwarn com.github.dart_lang.jni.**

# package_info_plus (8.3.1)
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-dontwarn dev.fluttercommunity.plus.packageinfo.**

# path_provider_android (2.3.0)
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# rive_native (0.1.5) — JNI nặng
-keep class app.rive.runtime.kotlin.** { *; }
-keep class app.rive.runtime.** { *; }
-dontwarn app.rive.runtime.**

# share_plus (10.1.4)
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# shared_preferences_android (2.4.23)
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# sqflite_android (2.4.2+3) — transitive qua flutter_cache_manager / cached_network_image
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# terminate_restart (1.1.0) — namespace có thể là tribblearts hoặc ahmedsleem
-keep class com.tribblearts.terminate_restart.** { *; }
-keep class com.ahmedsleem.terminate_restart.** { *; }
-dontwarn com.tribblearts.terminate_restart.**
-dontwarn com.ahmedsleem.terminate_restart.**

# url_launcher_android (6.3.29)
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# webview_flutter_android (4.11.0)
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# ──────────────────────────────────────────────────────────────────────────────
# AndroidX / Kotlin / Coroutines — phần lớn lib trên đều phụ thuộc
# ──────────────────────────────────────────────────────────────────────────────
-keep class androidx.lifecycle.** { *; }
-keep class androidx.activity.** { *; }
-keep class androidx.fragment.app.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.**

-keep class kotlin.Metadata { *; }
-keep class kotlin.reflect.** { *; }
-keep class kotlin.coroutines.** { *; }
-keep class kotlinx.coroutines.** { *; }
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ──────────────────────────────────────────────────────────────────────────────
# Network stack (transitive: OkHttp/Okio/Conscrypt) — một số plugin kéo về
# ──────────────────────────────────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep interface okhttp3.** { *; }

# WebView JavaScript interface (flutter_inappwebview / webview_flutter)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Native lib loading (rive, jni)
-keep class * {
    public <init>(android.content.Context);
}

# ──────────────────────────────────────────────────────────────────────────────
# App's own MainActivity
# ──────────────────────────────────────────────────────────────────────────────
-keep class com.app.caro.classic2026.** { *; }
-keep class com.app.caro.classic2026.MainActivity { *; }

# ──────────────────────────────────────────────────────────────────────────────
# Tránh warning chung cho Java desugar
# ──────────────────────────────────────────────────────────────────────────────
-dontwarn java.lang.invoke.**
-dontwarn java.lang.management.**
-dontwarn javax.annotation.**
