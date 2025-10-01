# Moi Église TV – Flutter App

Production-ready Flutter application for Moi Église TV with Firebase (Auth, Firestore, Storage, Messaging), localization, theming, live video, programmes, reels, and notifications.

## Prerequisites

- Flutter 3.10+ and Dart SDK 3+
- Android Studio (Android SDK), Xcode (for iOS)
- Node.js 18+ (only for optional Firestore seed script)
- A Firebase project with Firestore, Authentication, Storage, and Cloud Messaging enabled

## 1) Install & Bootstrap

```bash
git clone <this-repo-url>
cd <repo>
flutter pub get
```

## 2) Configure Firebase via FlutterFire

Install CLI and run configuration. This generates `lib/firebase_options.dart` and platform configs.

```bash
dart pub global activate flutterfire_cli
flutterfire configure \
  --platforms=android,ios,web \
  --project=<your-firebase-project-id>
```

Notes:
- Android: place the generated `google-services.json` under `android/app/`
- iOS: place `GoogleService-Info.plist` under `ios/Runner/` and run `cd ios && pod install`
- Web: `firebase_options.dart` must include a real web config (replace placeholders)

## 3) Platform Checks

Android
- Update `applicationId` in `android/app/build.gradle` to your real package id
- Ensure `compileSdkVersion/targetSdkVersion` are 34, and `minSdkVersion` ≥ 21
- Verify `android/app/src/main/AndroidManifest.xml` contains required permissions and uses `@mipmap/ic_launcher` for notification icon

iOS
- Add push notification capabilities, APNs keys in Firebase
- Ensure Info.plist contains camera/microphone/notification usage strings
- If using Facebook Login, add URL schemes and App ID entries

Web
- `web/index.html` and `web/manifest.json` are generic; ensure correct app name and icons if needed

## 4) Runtime configuration (env)

Pass env at build/run time with `--dart-define` (used by notifications backend sync):

```bash
--dart-define=BACKEND_API_URL=https://your-backend.com
```

## 5) Run & Build

Run (debug):
```bash
flutter run -d <device> --dart-define=BACKEND_API_URL=https://your-backend.com
```

Android release:
```bash
flutter build apk --release --dart-define=BACKEND_API_URL=https://your-backend.com
flutter build appbundle --release --dart-define=BACKEND_API_URL=https://your-backend.com
```

iOS release:
```bash
flutter build ios --release --dart-define=BACKEND_API_URL=https://your-backend.com
# Then archive/upload via Xcode
```

Web release:
```bash
flutter build web --release --dart-define=BACKEND_API_URL=https://your-backend.com
```

## Android release signing

1) Create a keystore (one-time):
```bash
keytool -genkey -v -keystore ~/keystores/moieglise.jks -keyalg RSA -keysize 2048 -validity 10000 -alias moieglise
```

2) Create `key.properties` in project root (never commit secrets):
```properties
storeFile=/absolute/path/to/moieglise.jks
storePassword=your-store-password
keyAlias=moieglise
keyPassword=your-key-password
```

3) Build signed release:
```bash
flutter build appbundle --release --dart-define=BACKEND_API_URL=https://your-backend.com
```

## 6) Feature QA Checklist (Step-by-step)

Authentication
- Email/Password: sign up, sign in, sign out, and forgot password dialog
- Google Sign-In: real credentials configured; user doc created in `users/{uid}`
- Facebook Login: real App ID/Client Token configured on Android/iOS; verify login
- Guest mode: tap “Continue as Guest” and verify navigation

Localization (FR/EN)
- In Settings, change language to EN and back to FR
- Verify labels across tabs: Live, Programmes, Reels, Settings, and screen headers

Theme
- Toggle dark mode in Settings; verify colors and that preference persists after app restart

Live Video
- In Firestore, create `liveStreams/main` with fields: `isActive: true`, `streamUrl: <HLS URL>`
- Open Live tab; verify player loads and retry flow shows on errors

Programmes
- Seed `programs` with ISO timestamps: `startTime`, `endTime`, `category`, `isLive`
- Test day filter (Today/Tomorrow/This week) and category chips; verify live badge and buttons

Reels
- Seed `reels` with `videoUrl`, `description`, `authorName`, `authorAvatar`, `likes`, `likeCount`, `commentCount`
- Verify playback, like/unlike behavior, comment sheet, and share action

Notifications
- Seed `notifications` with fields: `userId`, `title`, `message`, `type` (live_service/new_sermon/event_reminder), `read`
- Verify list loads, unread badge, mark-all-as-read, and toggle settings (UI)

Navigation & Splash
- App shows splash for ~3 seconds, then redirects to Auth (or Main after login)
- Bottom navigation switches between tabs and preserves state

## 7) Seed Test Data (optional)

A simple Node.js script is provided to seed Firestore with sample content.

Location: `scripts/seed/`

Usage:
```bash
cd scripts/seed
npm install

# Option A: Using GOOGLE_APPLICATION_CREDENTIALS to a service account JSON
export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/serviceAccount.json
USER_ID=<your-auth-uid> npm run seed

# Option B: Against local Firestore Emulator
export FIRESTORE_EMULATOR_HOST=localhost:8080
USER_ID=test-user npm run seed
```

The script seeds collections: `users`, `programs`, `reels`, `liveStreams`, and user-scoped `notifications`.

## 8) Troubleshooting

- Firebase initialization fails: re-run `flutterfire configure` and ensure `firebase_options.dart` contains real values for all platforms
- Android build issues: ensure Gradle, Kotlin, and Android Gradle Plugin versions match `android/build.gradle`
- iOS pods: run `cd ios && pod repo update && pod install`
- Web CORS/HLS: serve over HTTPS; ensure HLS source allows cross-origin playback
