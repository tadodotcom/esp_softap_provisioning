## [1.1.0]

* iOS: support Swift Package Manager (CocoaPods still works).
* iOS: the minimum deployment target is now iOS 13.0.
* iOS: the AES code is now Swift.
* iOS: `init` and `crypt` reply exactly once. `crypt` returns a `FlutterError`
  (`not_initialized`, `crypt_failed` or `invalid_arguments`) instead of
  crashing or never replying, and unknown methods return not implemented.
* Android: build with AGP 9 / Gradle 9, Java 17 bytecode and compileSdk 36.
  Drop the Kotlin plugin, `buildscript`, jcenter and the standalone Gradle
  wrapper.
* Require Dart 3.4 and Flutter 3.44, and pin dependency ranges.

## [1.0.1] - 2021-04-19
 
* Readme file is updated

## [1.0.0] - 2021-04-18
 
* Stable release for Espressif Esp32 Soft Ap provisioning with protobuf and cryptography.