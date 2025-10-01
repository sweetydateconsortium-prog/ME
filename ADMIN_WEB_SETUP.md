# Moi Église TV – Admin Web Setup

## What this is
A Flutter Web admin dashboard reusing your mobile theme to manage Programs, Live, Reels, Users, and Notifications with Firebase.

## Prerequisites
- Flutter 3.10+ and Dart 3+
- Firebase project with Auth, Firestore, Storage, Messaging enabled
- `lib/firebase_options.dart` has real web config
- Your admin user has custom claim `admin: true`

## Install dependencies
```bash
flutter pub get
```

## Run the Admin (web)
```bash
flutter run -d chrome -t lib/admin_web/main_admin.dart
```
- Redirects to `/admin/login` if not authenticated
- Non-admin users (no `admin: true`) are redirected back to login

## Grant admin access (one-time)
```javascript
// Node.js snippet
const admin = require('firebase-admin');
admin.initializeApp();
async function grantAdmin(userId) {
  await admin.auth().setCustomUserClaims(userId, { admin: true });
}
```
Sign out/in afterward to refresh claims.

## Firestore collections used
- `users` – counts, demo fan-out
- `programs` – CRUD from Programs page
- `reels` – counted on Dashboard
- `liveStreams/main` – start/stop live
- `notifications` – created by Notifications page

Minimal seed:
```javascript
// liveStreams/main
// data:
{ isActive: false, streamUrl: '' }
```

## Pages
- Dashboard: live counts for users/programs/reels
- Programs: list/add/delete (title, description)
- Live: update `liveStreams/main` (start/stop, streamUrl)
- Notifications: create in-app (single user or all users demo)
- Users/Settings: placeholders

## Firestore rules (example)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAdmin() { return request.auth.token.admin == true; }

    match /programs/{id} { allow read: if request.auth!=null; allow write: if isAdmin(); }
    match /liveStreams/{id} { allow read: if request.auth!=null; allow write: if isAdmin(); }
    match /notifications/{id} {
      allow read: if request.auth!=null && request.auth.uid == resource.data.userId;
      allow create: if isAdmin();
    }
    match /users/{id} { allow read: if request.auth!=null && request.auth.uid == id; }
  }
}
```
Note: “Send to all users” uses a client batch for demo. For large user bases, use a backend/Cloud Function (see `ADMIN_SETUP_GUIDE.md`).

## Build & Deploy (web)
```bash
flutter build web --release -t lib/admin_web/main_admin.dart
```
Host `build/web` (Firebase Hosting, static hosting, etc.). Point `admin.moieglise.tv` DNS to your hosting and deploy.

## Troubleshooting
- Login loops: user lacks `admin: true` or not signed in
- Permission denied: update rules and re-authenticate
- Counts zero: ensure data exists in collections
- Live not updating: verify `liveStreams/main` fields

## Next steps
- Add edit forms and advanced fields (Programs)
- Server-side Notifications via FCM topics
- Users table and details
- Sign-out action in admin shell