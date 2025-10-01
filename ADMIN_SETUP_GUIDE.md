# Moi Église TV - Administrator Interface Setup Guide

## 📋 Overview

This guide explains how to set up an administrator interface for managing the Moi Église TV backend content, including programs, live streams, reels, and user notifications.

---

## 🎯 Admin Interface Options

You have **3 main options** for managing your backend:

1. **Firebase Console (Quick Start)** - No coding, use Firebase's built-in UI
2. **Custom Web Admin Panel** - Build a React/Next.js admin dashboard
3. **Firebase Admin SDK + Backend API** - Programmatic control via Node.js/Python

---

## Option 1: Firebase Console (Recommended for Quick Start)

### ✅ Pros
- No development required
- Available immediately
- Secure by default
- No hosting costs

### ⚠️ Cons
- Limited customization
- Not user-friendly for non-technical staff
- No bulk operations UI
- No custom workflows

### Setup Instructions

#### 1. Access Firebase Console
1. Go to https://console.firebase.google.com
2. Select your project: `moi-eglise-tv-586e7`
3. Navigate to Firestore Database

#### 2. Manage Programs

**Add a New Program:**
```
Collection: programs
Document ID: [Auto-generate or custom ID]

Fields:
  title: string          // "Culte du Dimanche"
  description: string    // "Moment de louange et prière"
  category: string       // "culte", "enseignement", "musique", "jeunesse", "special"
  startTime: string      // ISO timestamp: "2024-12-15T07:00:00.000Z"
  endTime: string        // ISO timestamp: "2024-12-15T09:00:00.000Z"
  thumbnailUrl: string   // Full URL to image
  liveStreamUrl: string  // HLS URL (if live)
  isLive: boolean        // true/false
  isRecurring: boolean   // true/false
  tags: array            // ["culte", "louange"]
  host: map
    ├─ id: string
    ├─ name: string
    ├─ title: string
    └─ avatarUrl: string
  metadata: map
    ├─ viewCount: number
    ├─ likeCount: number
    ├─ rating: number
    ├─ reminders: array
    ├─ createdAt: string
    └─ updatedAt: string
```

**Edit/Delete Programs:**
- Click on any document in the `programs` collection
- Edit fields directly
- Click "Delete document" to remove

#### 3. Manage Live Streams

**Update Live Stream Status:**
```
Collection: liveStreams
Document ID: main

Fields:
  streamUrl: string      // "https://cdn.example.com/live.m3u8"
  backupUrl: string      // Backup stream URL
  isActive: boolean      // Set to true when going live
  quality: string        // "1080p", "720p", "480p"
  bitrate: number        // 5000
  viewers: number        // Current viewer count (manual or automated)
  startedAt: string      // ISO timestamp
```

**To Start Live Stream:**
1. Update `streamUrl` with your active HLS URL
2. Set `isActive` to `true`
3. Update `startedAt` to current timestamp

**To Stop Live Stream:**
1. Set `isActive` to `false`

#### 4. Manage Reels

**Add a New Reel:**
```
Collection: reels
Document ID: [Auto-generate]

Fields:
  title: string
  description: string
  videoUrl: string       // Full URL to video (MP4, HLS)
  thumbnailUrl: string
  authorId: string       // User ID
  authorName: string
  authorAvatar: string
  likes: array           // Array of user IDs who liked
  likeCount: number
  comments: array        // Or subcollection
  commentCount: number
  shares: number
  views: number
  duration: number       // In seconds
  tags: array
  createdAt: string      // ISO timestamp
```

#### 5. Send Notifications (Manual)

**Create User Notification:**
```
Collection: notifications
Document ID: [Auto-generate]

Fields:
  userId: string         // Target user ID or "all"
  title: string          // "Service en Direct!"
  message: string        // "Le culte commence maintenant"
  type: string           // "live_service", "new_sermon", "event_reminder"
  read: boolean          // false
  createdAt: string      // ISO timestamp
  metadata: map          // Optional additional data
    └─ action: string    // "open_live", "open_program:ID"
```

**For bulk notifications, see Option 3 below.**

#### 6. Manage Users

**View Users:**
```
Collection: users
```

**User Document Structure:**
```
Document ID: [User UID]

Fields:
  firstName: string
  lastName: string
  email: string
  phone: string
  city: string
  photoURL: string
  birthDate: string
  joinDate: string
  lastLoginAt: string
  preferences: map
    ├─ language: string
    ├─ darkMode: boolean
    └─ notifications: map
  stats: map
    ├─ watchedPrograms: array
    ├─ likedReels: array
    ├─ totalWatchTime: number
    └─ streakDays: number
  isActive: boolean
  createdAt: string
  updatedAt: string
```

**Common Admin Actions:**
- View user activity (stats)
- Disable accounts (set `isActive: false`)
- Update user roles (if implementing role-based access)

---

## Option 2: Custom Web Admin Panel

### ✅ Pros
- User-friendly interface
- Custom workflows
- Role-based access control
- Bulk operations
- Analytics dashboard

### ⚠️ Cons
- Requires development (2-4 weeks)
- Hosting costs
- Maintenance required

### Recommended Tech Stack

**Frontend:**
- React + Vite or Next.js
- Firebase JS SDK
- UI Library: Material-UI or Ant Design
- Authentication: Firebase Auth

**Backend:**
- Firebase Admin SDK (for server-side operations)
- Cloud Functions or Node.js server

### Quick Start Template

I recommend using **Firebase + Next.js Admin Template**:

#### 1. Initialize Next.js Project

```bash
npx create-next-app@latest moieglise-admin
cd moieglise-admin
npm install firebase firebase-admin
npm install @mui/material @mui/icons-material @emotion/react @emotion/styled
```

#### 2. Configure Firebase

**lib/firebase.js (Client-side):**
```javascript
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyCHUG1j4IOJNnwTPpBwb8coAaeEVHOeW2s",
  projectId: "moi-eglise-tv-586e7",
  // ... other config
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
```

**lib/firebaseAdmin.js (Server-side - API routes):**
```javascript
import admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

export const adminDb = admin.firestore();
export const adminAuth = admin.auth();
```

#### 3. Create Admin Pages

**pages/programs.js** - Program Management
```javascript
import { useState, useEffect } from 'react';
import { db } from '../lib/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';

export default function ProgramsPage() {
  const [programs, setPrograms] = useState([]);

  useEffect(() => {
    loadPrograms();
  }, []);

  const loadPrograms = async () => {
    const snapshot = await getDocs(collection(db, 'programs'));
    setPrograms(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
  };

  const addProgram = async (programData) => {
    await addDoc(collection(db, 'programs'), programData);
    loadPrograms();
  };

  const updateProgram = async (id, updates) => {
    await updateDoc(doc(db, 'programs', id), updates);
    loadPrograms();
  };

  const deleteProgram = async (id) => {
    await deleteDoc(doc(db, 'programs', id));
    loadPrograms();
  };

  return (
    <div>
      <h1>Manage Programs</h1>
      {/* Add UI components for CRUD operations */}
    </div>
  );
}
```

**pages/api/send-notification.js** - Bulk Notifications API
```javascript
import { adminDb } from '../../lib/firebaseAdmin';
import admin from 'firebase-admin';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { title, body, topic, data } = req.body;

  try {
    // Send via FCM topic
    await admin.messaging().send({
      topic: topic || 'all_users',
      notification: { title, body },
      data: data || {},
    });

    // Also create in-app notifications
    const notificationsRef = adminDb.collection('notifications');
    const batch = adminDb.batch();
    
    // Get all users (or filter by criteria)
    const usersSnapshot = await adminDb.collection('users').get();
    
    usersSnapshot.forEach(userDoc => {
      const notificationRef = notificationsRef.doc();
      batch.set(notificationRef, {
        userId: userDoc.id,
        title,
        message: body,
        type: data?.type || 'general',
        read: false,
        createdAt: new Date().toISOString(),
        metadata: data || {},
      });
    });

    await batch.commit();

    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

#### 4. Implement Authentication

**pages/login.js:**
```javascript
import { useState } from 'react';
import { auth } from '../lib/firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { useRouter } from 'next/router';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const router = useRouter();

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      await signInWithEmailAndPassword(auth, email, password);
      router.push('/dashboard');
    } catch (error) {
      alert('Login failed: ' + error.message);
    }
  };

  return (
    <form onSubmit={handleLogin}>
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit">Login</button>
    </form>
  );
}
```

#### 5. Deploy Admin Panel

**Option A: Vercel (Recommended)**
```bash
npm install -g vercel
vercel login
vercel deploy
```

**Option B: Firebase Hosting**
```bash
npm run build
firebase init hosting
firebase deploy --only hosting
```

**Security:** Set Firestore rules to restrict admin operations to specific user IDs:
```javascript
match /programs/{programId} {
  allow write: if request.auth.uid in ['ADMIN_USER_ID_1', 'ADMIN_USER_ID_2'];
}
```

---

## Option 3: Firebase Admin SDK + Backend API

### ✅ Pros
- Full programmatic control
- Can integrate with existing systems
- Automation friendly
- Scriptable operations

### ⚠️ Cons
- Requires backend development
- Not user-friendly for non-technical staff

### Setup Instructions

#### 1. Create Node.js Backend

```bash
mkdir moieglise-backend
cd moieglise-backend
npm init -y
npm install express firebase-admin dotenv cors
```

#### 2. Setup Firebase Admin SDK

**admin.js:**
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();
const auth = admin.auth();

module.exports = { admin, db, messaging, auth };
```

**Get Service Account Key:**
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Save as `serviceAccountKey.json` (NEVER commit to git)

#### 3. Create API Endpoints

**server.js:**
```javascript
const express = require('express');
const cors = require('cors');
const { db, messaging } = require('./admin');

const app = express();
app.use(express.json());
app.use(cors());

// ===== PROGRAMS =====

// Create program
app.post('/api/programs', async (req, res) => {
  try {
    const program = {
      ...req.body,
      metadata: {
        viewCount: 0,
        likeCount: 0,
        rating: 0,
        reminders: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
    };
    const docRef = await db.collection('programs').add(program);
    res.json({ success: true, id: docRef.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update program
app.put('/api/programs/:id', async (req, res) => {
  try {
    await db.collection('programs').doc(req.params.id).update({
      ...req.body,
      'metadata.updatedAt': new Date().toISOString(),
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete program
app.delete('/api/programs/:id', async (req, res) => {
  try {
    await db.collection('programs').doc(req.params.id).delete();
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all programs
app.get('/api/programs', async (req, res) => {
  try {
    const snapshot = await db.collection('programs').get();
    const programs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(programs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== LIVE STREAMS =====

// Start live stream
app.post('/api/live/start', async (req, res) => {
  try {
    const { streamUrl, backupUrl } = req.body;
    await db.collection('liveStreams').doc('main').set({
      streamUrl,
      backupUrl: backupUrl || '',
      isActive: true,
      quality: '1080p',
      bitrate: 5000,
      viewers: 0,
      startedAt: new Date().toISOString(),
    });
    
    // Send push notification
    await messaging.send({
      topic: 'all_users',
      notification: {
        title: 'Direct en Cours!',
        body: 'Le service est maintenant en direct',
      },
      data: {
        type: 'live_service',
        action: 'open_live',
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Stop live stream
app.post('/api/live/stop', async (req, res) => {
  try {
    await db.collection('liveStreams').doc('main').update({
      isActive: false,
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== NOTIFICATIONS =====

// Send notification to all users
app.post('/api/notifications/send', async (req, res) => {
  try {
    const { title, message, type, topic, targetUserIds } = req.body;

    // Send FCM push notification
    if (topic) {
      await messaging.send({
        topic,
        notification: { title, body: message },
        data: { type: type || 'general' },
      });
    }

    // Create in-app notifications
    const batch = db.batch();
    let users = [];

    if (targetUserIds && targetUserIds.length > 0) {
      users = targetUserIds;
    } else {
      const usersSnapshot = await db.collection('users').get();
      users = usersSnapshot.docs.map(doc => doc.id);
    }

    users.forEach(userId => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        userId,
        title,
        message,
        type: type || 'general',
        read: false,
        createdAt: new Date().toISOString(),
      });
    });

    await batch.commit();

    res.json({ success: true, sentTo: users.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== REELS =====

// Create reel
app.post('/api/reels', async (req, res) => {
  try {
    const reel = {
      ...req.body,
      likes: [],
      likeCount: 0,
      comments: [],
      commentCount: 0,
      shares: 0,
      views: 0,
      createdAt: new Date().toISOString(),
    };
    const docRef = await db.collection('reels').add(reel);
    res.json({ success: true, id: docRef.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== FCM TOKEN MANAGEMENT =====

// Store FCM token
app.post('/api/user/fcm-token', async (req, res) => {
  try {
    const { userId, token } = req.body;
    await db.collection('fcm_tokens').doc(userId).set({
      token,
      platform: 'android',
      updatedAt: new Date().toISOString(),
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== ANALYTICS =====

// Get dashboard stats
app.get('/api/analytics/dashboard', async (req, res) => {
  try {
    const [usersSnapshot, programsSnapshot, reelsSnapshot] = await Promise.all([
      db.collection('users').count().get(),
      db.collection('programs').count().get(),
      db.collection('reels').count().get(),
    ]);

    res.json({
      totalUsers: usersSnapshot.data().count,
      totalPrograms: programsSnapshot.data().count,
      totalReels: reelsSnapshot.data().count,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Admin API running on port ${PORT}`);
});
```

#### 4. Run the Backend

```bash
node server.js
```

#### 5. Use the API

**Create a program:**
```bash
curl -X POST http://localhost:3000/api/programs \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Culte du Dimanche",
    "description": "Service de louange",
    "category": "culte",
    "startTime": "2024-12-15T07:00:00.000Z",
    "endTime": "2024-12-15T09:00:00.000Z",
    "isLive": true
  }'
```

**Start live stream:**
```bash
curl -X POST http://localhost:3000/api/live/start \
  -H "Content-Type: application/json" \
  -d '{
    "streamUrl": "https://cdn.example.com/live.m3u8"
  }'
```

**Send notification:**
```bash
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Service en Direct",
    "message": "Rejoignez-nous maintenant!",
    "type": "live_service",
    "topic": "all_users"
  }'
```

#### 6. Deploy Backend

**Option A: Google Cloud Run**
```bash
gcloud run deploy moieglise-backend --source .
```

**Option B: Heroku**
```bash
heroku create moieglise-backend
git push heroku main
```

**Option C: Firebase Cloud Functions**
```bash
firebase init functions
# Move API endpoints to functions
firebase deploy --only functions
```

---

## 🔒 Security Best Practices

### 1. Firestore Rules

Ensure only authenticated admins can write:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAdmin() {
      return request.auth.uid in [
        'ADMIN_USER_ID_1',
        'ADMIN_USER_ID_2'
      ];
    }
    
    match /programs/{programId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    match /liveStreams/{streamId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
  }
}
```

### 2. Custom Claims (Recommended)

Set admin custom claims:

```javascript
const admin = require('firebase-admin');

// Set admin claim
await admin.auth().setCustomUserClaims(userId, { admin: true });
```

**Then in Firestore rules:**
```javascript
function isAdmin() {
  return request.auth.token.admin == true;
}
```

### 3. API Authentication

For backend API, use Firebase ID tokens:

```javascript
const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

app.post('/api/programs', verifyToken, async (req, res) => {
  // Only authenticated users can access
});
```

---

## 📱 Quick Admin Actions via Firebase Console

### Start a Live Stream
1. Go to Firestore > `liveStreams` > `main`
2. Update fields:
   - `streamUrl`: Your HLS URL
   - `isActive`: `true`
   - `startedAt`: Current timestamp

### Schedule a Program
1. Go to Firestore > `programs` > Add document
2. Fill in all required fields
3. Set `startTime` and `endTime` in ISO format

### Send a Quick Notification
1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Fill notification details
4. Select target: All users or topic
5. Send

---

## 📊 Recommended Admin Workflows

### Daily Operations
1. Check live stream status (Firestore > liveStreams)
2. Review scheduled programs for today
3. Monitor user activity (Analytics)
4. Check for new user signups

### Weekly Tasks
1. Add next week's program schedule
2. Upload new reel content
3. Send weekly newsletter notification
4. Review and moderate user-generated content

### Monthly Tasks
1. Analyze user engagement metrics
2. Update recurring programs
3. Archive old content
4. Backup Firestore data

---

## 🎉 Conclusion

**Recommended Approach:**

- **Short Term (Week 1):** Use Firebase Console for immediate needs
- **Medium Term (Month 1-2):** Build custom web admin panel for better UX
- **Long Term:** Automate workflows with backend API

Choose the option that best fits your technical skills and immediate needs. You can always start with Option 1 and migrate to Options 2 or 3 later.

---

## 📚 Additional Resources

- [Firebase Console](https://console.firebase.google.com)
- [Firebase Admin SDK Docs](https://firebase.google.com/docs/admin/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [FCM Send Notifications](https://firebase.google.com/docs/cloud-messaging/send-message)

For questions or assistance, refer to the project README.md and SETUP_GUIDE.md files.
