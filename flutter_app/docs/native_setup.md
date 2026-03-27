# Native setup after installing Flutter SDK

The repository currently contains the Flutter client source and shared app logic, but the native iOS/Android folders still need to be generated with `flutter create .` once Flutter is installed locally.

## iOS

- Add URL types for `lupilup` in `ios/Runner/Info.plist`.
- Ensure the app can open:
  - `lupilup://auth/callback`
  - `lupilup://oauth/ravelry`
- For `google_mlkit_text_recognition`, follow the package pod install steps after `flutter pub get`.

## Android

- Add intent filters for the `lupilup` scheme in `android/app/src/main/AndroidManifest.xml`.
- Verify the launch activity accepts deep links for:
  - `lupilup://auth/callback`
  - `lupilup://oauth/ravelry`
- Confirm camera and photo library permissions for `image_picker`.

## Validation checklist

- `flutter pub get`
- `flutter create .`
- `flutter run` on iOS simulator and Android emulator
- Verify Google OAuth return to app
- Verify magic link return to app
- Verify Ravelry OAuth import return to app

