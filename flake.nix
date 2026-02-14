{
  description = "Orion Viewer - Android PDF/DJVU reader build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        buildToolsVersion = "35.0.0";
        ndkVersion = "23.2.8568313";
        cmakeVersion = "3.22.1";
        platformVersion = "35";

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersion ];
          platformVersions = [ platformVersion ];
          abiVersions = [ "x86" "x86_64" "armeabi-v7a" "arm64-v8a" ];
          includeNDK = true;
          ndkVersions = [ ndkVersion ];
          cmakeVersions = [ cmakeVersion ];
          includeEmulator = false;
          includeSystemImages = false;
          includeSources = false;
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default = pkgs.mkShell {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk/${ndkVersion}";
          JAVA_HOME = "${pkgs.jdk17}";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";

          buildInputs = [
            androidSdk
            pkgs.jdk17
            pkgs.gradle
          ];
        };
      });
}
