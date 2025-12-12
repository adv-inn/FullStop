# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Spotify SDK rules
-keep class com.spotify.** { *; }
-keep class com.spotify.protocol.** { *; }
-keep class com.spotify.android.** { *; }
-dontwarn com.spotify.**

# Jackson (used by Spotify SDK)
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# Spotify base annotations
-dontwarn com.spotify.base.annotations.**

# Google Play Core (not used but referenced by Flutter)
-dontwarn com.google.android.play.core.**
