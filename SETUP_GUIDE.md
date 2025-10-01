# Moi Église TV - Flutter Setup Guide

## 🔥 Complete Setup to Make App Fully Functional

### 1A. **Facebook Login Setup**

#### Step 1: Create a Facebook App
1. Go to https://developers.facebook.com/apps/
2. Click "Create App" and follow the steps for a Consumer app.
3. Add Facebook Login as a product.
4. In the Facebook app dashboard, go to Settings > Basic and copy your App ID and App Secret.

#### Step 2: Configure Facebook Login in Firebase
1. Go to Firebase Console > Authentication > Sign-in method.
2. Enable Facebook.
3. Enter your Facebook App ID and App Secret.
4. Set the OAuth redirect URI in Facebook: `https://<your-project-id>.firebaseapp.com/__/auth/handler`

#### Step 3: Android Setup
1. Add your app's package name and SHA-1 key to the Facebook app settings.
2. Add the following to your `android/app/src/main/res/values/strings.xml`:
   ```xml
   <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
   ```
3. Add the following to your `android/app/src/main/AndroidManifest.xml` inside `<application>`:
   ```xml
   <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
   <activity android:name="com.facebook.FacebookActivity" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="@string/app_name" />
   <provider android:name="com.facebook.internal.FacebookInitProvider" android:authorities="com.facebook.app.FacebookContentProviderYOUR_FACEBOOK_APP_ID" android:exported="false" />
   ```

#### Step 4: iOS Setup
1. Add your bundle identifier to the Facebook app settings.
2. Add the following to your `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>fbYOUR_FACEBOOK_APP_ID</string>
       </array>
     </dict>
   </array>
   <key>FacebookAppID</key>
   <string>YOUR_FACEBOOK_APP_ID</string>
   <key>FacebookDisplayName</key>
   <string>Moi Église TV</string>
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>fbapi</string>
     <string>fb-messenger-api</string>
     <string>fbauth2</string>
     <string>fbshareextension</string>
   </array>
   ```
3. Run `pod install` in the `ios` directory after editing the plist.

#### Step 5: Add flutter_facebook_auth to pubspec.yaml
```yaml
flutter_facebook_auth: ^6.1.1
```

#### Step 6: Test Facebook Login
1. Build and run your app on a real device (Facebook login does not work on emulators/simulators).
2. Try logging in with Facebook and verify user creation in Firebase.

### 1. **Firebase Project Setup**

#### Step 1: Create Firebase Project
```bash
# Go to https://console.firebase.google.com/
# Create new project: "moi-eglise-tv"
# Enable Google Analytics (optional)
```

#### Step 2: Configure Firebase for Flutter
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
cd flutter_app
flutterfire configure
```

This will generate real `firebase_options.dart` and platform-specific config files.

#### Step 3: Enable Firebase Services
```bash
# Enable Authentication
# Go to Firebase Console > Authentication > Sign-in method
# Enable: Email/Password, Google, Apple (if needed)

# Enable Firestore
# Go to Firebase Console > Firestore Database > Create database
# Start in test mode, then apply security rules

# Enable Cloud Storage
# Go to Firebase Console > Storage > Get started

# Enable Cloud Messaging
# Go to Firebase Console > Cloud Messaging
```

### 2. **Android Configuration**

#### Add to `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

<application>
    <!-- Firebase Messaging Service -->
    <service
        android:name=".NotificationService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- Notification channels -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="moi_eglise_channel" />
</application>
```

### 3. **iOS Configuration**

#### Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>L'app a besoin d'accès à la caméra pour les fonctionnalités de profil</string>
<key>NSMicrophoneUsageDescription</key>
<string>L'app a besoin d'accès au microphone pour les fonctionnalités audio</string>
<key>NSUserNotificationsUsageDescription</key>
<string>L'app envoie des notifications pour les services et événements</string>
```

### 4. **Firebase Backend Data Structure**

#### Create Firestore Collections:
```javascript
// Run in Firebase Console or use the backend setup script

// 1. Users Collection
db.collection('users').doc('example').set({
  firstName: "Jean",
  lastName: "Dupont",
  email: "jean@example.com",
  phone: "+33123456789",
  city: "Paris",
  birthDate: "1990-01-01T00:00:00.000Z",
  joinDate: "2024-01-01T00:00:00.000Z",
  preferences: {
    language: "fr",
    darkMode: false,
    notifications: {
      liveServices: true,
      newSermons: true,
      events: true,
      prayerMeetings: true,
      testimonies: false
    }
  },
  stats: {
    watchedPrograms: [],
    likedReels: [],
    totalWatchTime: 0,
    streakDays: 0
  }
});

// 2. Programs Collection
db.collection('programs').doc('example').set({
  title: "Culte du Matin",
  description: "Moment de louange et d'adoration",
  category: "culte",
  startTime: "2024-12-01T07:00:00.000Z",
  endTime: "2024-12-01T09:00:00.000Z",
  thumbnailUrl: "https://example.com/thumb.jpg",
  liveStreamUrl: "https://stream.example.com/live.m3u8",
  isLive: true,
  isRecurring: true,
  tags: ["culte", "louange"],
  host: {
    id: "host1",
    name: "Pasteur Martin",
    title: "Pasteur Principal",
    avatarUrl: "https://example.com/avatar.jpg"
  },
  metadata: {
    viewCount: 0,
    likeCount: 0,
    rating: 0.0,
    reminders: [],
    createdAt: "2024-01-01T00:00:00.000Z",
    updatedAt: "2024-01-01T00:00:00.000Z"
  }
});

// 3. Reels Collection
db.collection('reels').doc('example').set({
  title: "Témoignage Miraculeux",
  description: "Un témoignage puissant de guérison divine",
  videoUrl: "https://storage.googleapis.com/your-bucket/reels/video1.mp4",
  thumbnailUrl: "https://storage.googleapis.com/your-bucket/reels/thumb1.jpg",
  authorId: "user123",
  authorName: "Marie Dupont",
  authorAvatar: "https://example.com/marie.jpg",
  likes: [],
  likeCount: 0,
  comments: [],
  commentCount: 0,
  shares: 0,
  views: 0,
  duration: 30,
  tags: ["témoignage", "miracle"],
  createdAt: "2024-01-01T00:00:00.000Z"
});

// 4. Live Streams Collection
db.collection('liveStreams').doc('main').set({
  streamUrl: "https://your-stream-provider.com/live.m3u8",
  backupUrl: "https://backup-stream.com/live.m3u8",
  isActive: true,
  quality: "1080p",
  bitrate: 5000,
  viewers: 0,
  startedAt: "2024-01-01T07:00:00.000Z"
});
```

### 5. **Video Streaming Setup**

#### Option 1: Use Firebase Storage + HLS
```bash
# Upload video files to Firebase Storage
# Use a service like Mux or Vimeo for HLS streaming
```

#### Option 2: Use YouTube Live API
```dart
// In your streaming service
final String youtubeStreamUrl = "https://www.youtube.com/embed/YOUR_LIVE_ID";
```

#### Option 3: Use Custom RTMP Server
```bash
# Setup NGINX with RTMP module
# Configure HLS streaming endpoints
```

### 6. **Security Rules**

#### Firestore Security Rules (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Programs are readable by all authenticated users
    match /programs/{programId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins via backend
    }
    
    // Reels are readable by all, writable by creator
    match /reels/{reelId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.authorId || 
         request.auth.uid in resource.data.likes);
    }
    
    // Live streams are readable by all
    match /liveStreams/{streamId} {
      allow read: if request.auth != null;
      allow write: if false; // Only backend updates
    }
  }
}
```

#### Storage Security Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /reels/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /programs/{allPaths=**} {
      allow read: if request.auth != null;
    }
  }
}
```

### 7. **Environment Variables**

Create `.env` file in the root:
```env
# Firebase
FIREBASE_PROJECT_ID=moi-eglise-tv
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=moi-eglise-tv.firebaseapp.com
FIREBASE_STORAGE_BUCKET=moi-eglise-tv.appspot.com

# Streaming
LIVE_STREAM_URL=https://your-stream.com/live.m3u8
BACKUP_STREAM_URL=https://backup-stream.com/live.m3u8

# Analytics
ANALYTICS_ENABLED=true
```

### 8. **Build and Deploy**

#### Build for Android:
```bash
cd flutter_app
flutter build apk --release
# or
flutter build appbundle --release
```

#### Build for iOS:
```bash
flutter build ios --release
# Then use Xcode to archive and upload to App Store
```

### 9. **Testing Checklist**

- [ ] Firebase Authentication (Email, Google)
- [ ] Guest mode access
- [ ] Live video streaming
- [ ] Programs loading from Firestore
- [ ] Reels playback and interactions
- [ ] Push notifications
- [ ] Dark/Light theme switching
- [ ] French/English language switching
- [ ] Profile management
- [ ] Offline functionality

### 10. **Production Optimizations**

#### Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - .env
```

#### Performance monitoring:
```dart
// Add Firebase Performance
import 'package:firebase_performance/firebase_performance.dart';

// Track app performance
FirebasePerformance.instance.isPerformanceCollectionEnabled();
```

## 🚀 **What's Still Mock vs Real**

### ✅ **Now Real/Production Ready:**
- Firebase Authentication
- User profile management  
- Real-time Firestore data
- Push notifications
- File uploads to Storage
- Security rules
- Multi-language support
- Theme management

### ⚠️ **Still Needs Real Implementation:**
- **Live streaming URLs** (need actual RTMP/HLS endpoints)
- **Video content** (need real video files in Firebase Storage)
- **Payment integration** (if donations needed)
- **Admin panel** (for content management)
- **Analytics dashboard** (Firebase Analytics setup)

## 🔧 **Key Next Steps:**

### 1B. **FCM Token Backend Integration**

#### Step 1: Backend API Endpoint
Your backend should expose an endpoint to receive and store FCM tokens for users, e.g.:
```
POST /api/user/fcm-token
{
  "userId": "<USER_ID>",
  "token": "<FCM_TOKEN>"
}
```

#### Step 2: Environment Variable
Add your backend API URL to your `.env` file:
```
BACKEND_API_URL=https://your-backend.com
```

#### Step 3: Flutter App Configuration
The app will automatically send the FCM token to the backend when it is generated or refreshed, using the `BACKEND_API_URL` environment variable. Make sure to rebuild your app after updating `.env`.

#### Step 4: Test Integration
1. Run your backend and the app.
2. Log in and check your backend logs or database to verify the FCM token is received and stored for the user.

1. **Setup actual Firebase project** with real config
2. **Upload real video content** to Firebase Storage
3. **Configure live streaming** infrastructure
4. **Add payment gateway** (Stripe, PayPal) if needed
5. **Build admin panel** for content management
6. **Setup CI/CD pipeline** for deployments
7. **Add crash reporting** (Firebase Crashlytics)
8. **Performance monitoring** setup

The Flutter app architecture is production-ready! You just need to connect it to real data sources and configure the Firebase project properly.