# Moi Église TV - Quick Start for Administrators

## 🎯 5-Minute Admin Setup Guide

This guide gets you managing content in under 5 minutes using Firebase Console.

---

## Step 1: Access Firebase Console (1 min)

1. Go to: https://console.firebase.google.com
2. Select project: **moi-eglise-tv-586e7**
3. Click on **Firestore Database** in left sidebar

---

## Step 2: Go Live with Your Stream (2 min)

### Start Broadcasting:

1. In Firestore, navigate to: **liveStreams** → **main**
2. Click **Edit Document**
3. Update these fields:
   - `streamUrl`: Paste your HLS stream URL (ends with .m3u8)
   - `isActive`: Change to **true**
   - `startedAt`: Click "Use current timestamp"
4. Click **Update**

✅ **Your live stream is now active in the app!**

### Stop Broadcasting:

1. Edit the **main** document again
2. Set `isActive` to **false**
3. Click **Update**

---

## Step 3: Add a Program (2 min)

1. In Firestore, navigate to **programs** collection
2. Click **Add document**
3. Set **Document ID**: auto-generate or custom (e.g., "sunday-service-001")
4. Add these fields (click "+ Add field" for each):

| Field | Type | Example Value |
|-------|------|---------------|
| title | string | "Culte du Dimanche" |
| description | string | "Moment de louange et prière" |
| category | string | "culte" |
| startTime | string | "2024-12-15T07:00:00.000Z" |
| endTime | string | "2024-12-15T09:00:00.000Z" |
| isLive | boolean | true |
| isRecurring | boolean | false |
| thumbnailUrl | string | (URL to image) |
| tags | array | ["culte", "louange"] |

5. Add nested **host** map:
   - Click "+ Add field"
   - Field name: `host`
   - Type: **map**
   - Add sub-fields:
     - `name`: string → "Pasteur Martin"
     - `title`: string → "Pasteur Principal"
     - `id`: string → "host-001"

6. Add nested **metadata** map:
   - Field name: `metadata`
   - Type: **map**
   - Add sub-fields:
     - `viewCount`: number → 0
     - `likeCount`: number → 0
     - `rating`: number → 0
     - `createdAt`: string → "2024-12-15T00:00:00.000Z"

7. Click **Save**

✅ **Program now appears in the app!**

---

## Common Admin Tasks

### 📺 Manage Live Stream

**Location:** Firestore → liveStreams → main

```
Start Live:  isActive = true
Stop Live:   isActive = false
Change URL:  streamUrl = "https://new-url.m3u8"
```

---

### 📅 Schedule Programs

**Location:** Firestore → programs → Add document

**Categories:**
- `culte` - Worship services
- `enseignement` - Teachings
- `musique` - Music/concerts
- `jeunesse` - Youth programs
- `special` - Special events

**Date Format:** ISO 8601
```
"2024-12-15T07:00:00.000Z"
```

Use: https://www.timestamp-converter.com to convert dates

---

### 🎬 Add Reels

**Location:** Firestore → reels → Add document

**Required fields:**
```
title:         "Témoignage Puissant"
description:   "Un témoignage de guérison"
videoUrl:      "https://storage/.../video.mp4"
authorName:    "Marie Dupont"
authorId:      "user-id-123"
authorAvatar:  "https://avatar-url.jpg"
likes:         [] (empty array)
likeCount:     0
commentCount:  0
views:         0
createdAt:     "2024-12-15T00:00:00.000Z"
```

---

### 🔔 Send Notification

**Option 1: Firebase Console (Quick)**
1. Go to: Firebase Console → **Cloud Messaging**
2. Click **Send your first message** (or **New campaign**)
3. Fill in:
   - Notification title: "Service en Direct!"
   - Notification text: "Rejoignez-nous maintenant"
4. Select **Target:** All users (or specific topic like "all_users")
5. Click **Review** → **Publish**

**Option 2: Firestore (In-App Only)**
1. Go to: Firestore → **notifications** → Add document
2. Add fields:
   - `userId`: "all" or specific user ID
   - `title`: "Service en Direct"
   - `message`: "Le culte commence dans 15 minutes"
   - `type`: "live_service"
   - `read`: false
   - `createdAt`: Current timestamp

---

## 🎨 Quick Reference: Field Types

| Firebase Type | What It Means | Example |
|--------------|---------------|---------|
| **string** | Text | "Hello World" |
| **number** | Number (integer or decimal) | 42 or 3.14 |
| **boolean** | True/False | true or false |
| **array** | List of items | ["item1", "item2"] |
| **map** | Nested object | {name: "John", age: 30} |
| **timestamp** | Date/time | Click "Use current timestamp" |

---

## 📋 Daily Checklist

### Morning Routine (5 min)
- [ ] Check if live stream URL is correct
- [ ] Verify today's programs are scheduled
- [ ] Review any new user comments/feedback

### Before Going Live (2 min)
- [ ] Update liveStreams/main: `isActive = true`
- [ ] Update streamUrl if changed
- [ ] Optional: Send notification to users

### After Stream (2 min)
- [ ] Set liveStreams/main: `isActive = false`
- [ ] Check viewer statistics (if tracking)
- [ ] Upload recording as reel (optional)

---

## 🆘 Troubleshooting

### "My live stream doesn't show in the app"

**Check:**
1. Firestore → liveStreams → main → `isActive` = true
2. `streamUrl` is a valid HLS URL (ends with .m3u8)
3. Stream URL is accessible (open in browser)
4. Users have refreshed the app

---

### "Program doesn't appear in the list"

**Check:**
1. `startTime` and `endTime` are in ISO format
2. Times are in the future (or current for live programs)
3. `isLive` is set correctly
4. Category is one of: culte, enseignement, musique, jeunesse, special

---

### "Notification wasn't received"

**Check:**
1. Users have notifications enabled in app settings
2. If using topics, ensure topic name is correct
3. Allow 1-2 minutes for delivery
4. Test with your own device first

---

## 📞 Need Help?

### Documentation Files:
- **Full Setup Guide:** SETUP_GUIDE.md
- **Admin Interface Guide:** ADMIN_SETUP_GUIDE.md
- **Deployment Checklist:** DEPLOYMENT_CHECKLIST.md
- **Project Status:** PROJECT_STATUS_REPORT.md

### Firebase Resources:
- **Console:** https://console.firebase.google.com
- **Firestore Docs:** https://firebase.google.com/docs/firestore
- **Cloud Messaging:** https://firebase.google.com/docs/cloud-messaging

---

## 🚀 Advanced: Using the Seed Script

If you need to add multiple programs quickly:

```bash
# Navigate to seed script
cd scripts/seed

# Install dependencies (first time only)
npm install

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json

# Run seed script
USER_ID=your-user-id npm run seed
```

This adds:
- 2 sample programs
- 1 sample reel
- Live stream configuration
- 2 test notifications

Edit `scripts/seed/seed.js` to customize the data.

---

## 💡 Pro Tips

1. **Use Auto-IDs:** Let Firebase generate document IDs automatically
2. **Batch Updates:** Update multiple programs at once using the seed script
3. **Test First:** Always test changes on your own device before announcing
4. **Backup:** Export Firestore data monthly (Cloud Console → Export)
5. **Monitor Usage:** Check Firebase Console → Usage tab weekly

---

## 🎉 You're Ready!

You now know how to:
- ✅ Start and stop live streams
- ✅ Add programs to the schedule
- ✅ Upload reels content
- ✅ Send notifications to users
- ✅ Troubleshoot common issues

**Time to go live!** 🎥📺

For more advanced admin features, see **ADMIN_SETUP_GUIDE.md** to build a custom admin dashboard.
