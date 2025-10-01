# Moi Église TV - Deployment Timeline

## 🗓️ Complete Deployment Schedule

This document provides a realistic timeline from current state to Google Play Store deployment.

---

## Current Status: **READY TO DEPLOY**

✅ All features implemented  
✅ Firebase configured  
✅ Android build setup complete  
⚠️ Needs: Signing config, content, stream URL

---

## 📅 Timeline Options

### Option A: Rapid Deployment (Same Day - 4 hours)

**Goal:** Get a working APK deployed for testing TODAY

| Time | Task | Duration | Critical? |
|------|------|----------|-----------|
| **Hour 1** | **Setup & Configuration** | 60 min | ✅ Critical |
| 0:00 | Generate release keystore | 15 min | ✅ |
| 0:15 | Create key.properties file | 5 min | ✅ |
| 0:20 | Test keystore with debug build | 10 min | ✅ |
| 0:30 | Set up test live stream URL | 20 min | ✅ |
| 0:50 | Update Firebase config (if needed) | 10 min | 🟡 |
| **Hour 2** | **Content & Security** | 60 min | 🟡 Important |
| 1:00 | Deploy Firestore security rules | 15 min | 🟡 |
| 1:15 | Run seed script (add test data) | 15 min | 🟡 |
| 1:30 | Add 3-5 real programs manually | 20 min | 🟡 |
| 1:50 | Upload 1-2 test reel videos | 10 min | 🟡 |
| **Hour 3** | **Build & Test** | 60 min | ✅ Critical |
| 2:00 | Clean and get dependencies | 5 min | ✅ |
| 2:05 | Build release APK | 10 min | ✅ |
| 2:15 | Install on test device | 5 min | ✅ |
| 2:20 | Test all features | 30 min | ✅ |
| 2:50 | Fix any critical issues | 10 min | ✅ |
| **Hour 4** | **Distribution** | 60 min | |
| 3:00 | Build final signed APK/AAB | 10 min | ✅ |
| 3:10 | Share APK for internal testing | 10 min | |
| 3:20 | Document deployment notes | 20 min | |
| 3:40 | Create backup & rollback plan | 20 min | |

**Outcome:** Working signed APK ready for distribution or Play Store upload

---

### Option B: Standard Deployment (3 Days)

**Goal:** Properly tested, polished release

#### Day 1: Configuration & Content (4-6 hours)

**Morning Session (2-3 hours):**
- [ ] Generate release keystore (15 min)
- [ ] Configure signing in Gradle (15 min)
- [ ] Set up production live stream infrastructure (1-2 hours)
- [ ] Configure backend API for FCM tokens (30 min)
- [ ] Test backend connectivity (30 min)

**Afternoon Session (2-3 hours):**
- [ ] Deploy Firestore security rules (30 min)
- [ ] Deploy Storage security rules (30 min)
- [ ] Create real program schedule (1 hour)
- [ ] Upload video content for reels (30-60 min)
- [ ] Configure Facebook Login (optional, 30 min)

#### Day 2: Testing & Refinement (6-8 hours)

**Morning (3-4 hours):**
- [ ] Build release APK (15 min)
- [ ] Test on 3+ Android devices (different versions) (2 hours)
- [ ] Test all authentication methods (1 hour)
- [ ] Test live streaming (30 min)
- [ ] Test notifications (30 min)

**Afternoon (3-4 hours):**
- [ ] Fix any bugs discovered (2 hours)
- [ ] Performance testing (1 hour)
- [ ] Security review (1 hour)
- [ ] Create release notes (30 min)

#### Day 3: Play Store Preparation & Launch (4-6 hours)

**Morning (2-3 hours):**
- [ ] Create Play Console account (30 min)
- [ ] Prepare store listing (1-2 hours)
  - App description (FR & EN)
  - Screenshots (5-10 images)
  - Feature graphic
  - Privacy policy
- [ ] Create promotional materials (30 min)

**Afternoon (2-3 hours):**
- [ ] Build final App Bundle (15 min)
- [ ] Upload to Play Console (30 min)
- [ ] Complete all store requirements (1 hour)
- [ ] Submit for review (15 min)
- [ ] Set up monitoring (30 min)

**Outcome:** App submitted to Play Store (review takes 2-7 days)

---

### Option C: Enterprise Deployment (2 Weeks)

**Goal:** Production-grade release with admin panel and full testing

#### Week 1: Infrastructure & Content

**Days 1-2:** Backend Setup
- [ ] Set up production backend API
- [ ] Configure admin authentication
- [ ] Implement FCM token management
- [ ] Set up monitoring and logging
- [ ] Deploy to production server

**Days 3-4:** Admin Interface
- [ ] Choose admin panel approach (Firebase Console, custom, or API)
- [ ] Set up admin panel (if custom)
- [ ] Configure admin user accounts
- [ ] Test admin workflows
- [ ] Train staff on admin interface

**Day 5:** Content & Security
- [ ] Finalize live streaming infrastructure
- [ ] Create comprehensive program schedule
- [ ] Upload all initial video content
- [ ] Deploy and test security rules
- [ ] Set up backup procedures

#### Week 2: Testing & Launch

**Days 6-7:** Quality Assurance
- [ ] Internal alpha testing (5+ devices)
- [ ] Feature testing (all scenarios)
- [ ] Performance testing
- [ ] Security audit
- [ ] Fix all critical and high-priority bugs

**Days 8-9:** Beta Testing
- [ ] Closed beta (10-20 users)
- [ ] Gather feedback
- [ ] Analytics review
- [ ] Bug fixing
- [ ] Performance optimization

**Day 10:** Play Store Launch
- [ ] Finalize store materials
- [ ] Build production release
- [ ] Submit to Play Store
- [ ] Prepare launch communications
- [ ] Set up support channels

**Outcome:** Robust, well-tested production app

---

## 🎯 Recommended Approach: **Option B (3 Days)**

**Why?**
- Balanced between speed and quality
- Adequate testing time
- Proper security configuration
- Professional store presence
- Manageable workload

---

## 📋 Detailed Task Breakdown

### Critical Path Tasks (Must Complete)

#### 1. Release Signing (30 min - BLOCKING)

```bash
# Generate keystore
keytool -genkey -v -keystore ~/keystores/moieglise.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias moieglise

# Create key.properties
echo "storeFile=/absolute/path/to/moieglise.jks
storePassword=YOUR_PASSWORD
keyAlias=moieglise
keyPassword=YOUR_PASSWORD" > android/key.properties
```

**Verification:**
```bash
flutter build apk --release
# Should complete without signing errors
```

---

#### 2. Live Stream Configuration (1-2 hours - BLOCKING)

**Option A: Use Test Stream**
```javascript
// Firestore: liveStreams/main
{
  streamUrl: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
  isActive: true
}
```

**Option B: Set Up Production Stream**
1. Choose streaming service (Mux, Wowza, custom RTMP)
2. Configure HLS output
3. Test stream URL
4. Update Firestore

**Verification:**
- Open URL in VLC player
- Stream loads in app's Live tab
- Video plays without errors

---

#### 3. Content Population (1-2 hours - IMPORTANT)

**Minimum Viable Content:**
- 5 programs (varied schedule)
- 2-3 reels videos
- 1 active live stream config

**Using Seed Script:**
```bash
cd scripts/seed
npm install
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
USER_ID=admin-user-id npm run seed
```

**Verification:**
- Programs appear in Programmes tab
- Reels load in Reels tab
- Content displays correctly

---

#### 4. Security Rules (30 min - CRITICAL)

**Deploy Firestore Rules:**
```bash
# Create firestore.rules (see ADMIN_SETUP_GUIDE.md)
firebase deploy --only firestore:rules
```

**Deploy Storage Rules:**
```bash
# Create storage.rules (see ADMIN_SETUP_GUIDE.md)
firebase deploy --only storage
```

**Verification:**
- Test read access (should work)
- Test write access as non-admin (should fail)
- Test admin write access (should work if configured)

---

#### 5. Build & Test (2 hours - CRITICAL)

**Build Commands:**
```bash
# Clean build
flutter clean
flutter pub get

# Release APK
flutter build apk --release \
  --dart-define=BACKEND_API_URL=https://your-backend.com

# Release App Bundle (for Play Store)
flutter build appbundle --release \
  --dart-define=BACKEND_API_URL=https://your-backend.com
```

**Test Checklist:**
- [ ] App launches (no crashes)
- [ ] Authentication works (email + Google)
- [ ] Live tab loads stream
- [ ] Programs list populated
- [ ] Reels play correctly
- [ ] Notifications can be received
- [ ] Theme switching works
- [ ] Language switching works
- [ ] User can edit profile

---

### Optional Tasks (Enhance but not block)

#### Backend API (2-3 hours)

**If skipping:**
- FCM tokens won't sync to backend
- Notifications still work via topics
- Can add later without app update

**If implementing:**
```bash
# See ADMIN_SETUP_GUIDE.md for full API code
node server.js
```

---

#### Facebook Login (30 min)

**If skipping:**
- Email and Google login still work
- Can enable later via Firebase Console

**If implementing:**
1. Create Facebook App
2. Add App ID to strings.xml
3. Test on device

---

#### Custom Admin Panel (1-2 weeks)

**If skipping:**
- Use Firebase Console for content management
- See QUICK_START_ADMIN.md

**If implementing:**
- See ADMIN_SETUP_GUIDE.md Option 2

---

## 📊 Resource Requirements

### Personnel

**Minimum Team:**
- 1 Developer (Flutter + Firebase experience)
- 1 Content Manager (for program scheduling)

**Ideal Team:**
- 1 Senior Developer (Flutter)
- 1 Backend Developer (Node.js/Firebase)
- 1 QA Tester
- 1 Content Manager
- 1 DevOps Engineer (optional)

### Infrastructure

**Required:**
- Firebase Blaze plan ($0 + usage)
- Live streaming service ($50-500/month depending on provider)
- Domain name for backend API (optional, $10/year)

**Optional:**
- Hosting for admin panel ($5-20/month)
- CDN for video content ($20-100/month)

### Budget Estimate

**One-Time Costs:**
- Google Play Console account: $25
- Domain name (optional): $10-15/year

**Monthly Costs:**
- Firebase (1000 users): $20-50
- Live streaming service: $50-500
- Hosting (if needed): $5-20
- **Total:** $75-570/month

---

## 🚨 Risk Mitigation

### Critical Risks

**Risk 1: Keystore Loss**
- **Impact:** Can't update app
- **Mitigation:** Backup keystore to 3 locations
- **Recovery:** Create new app (lose user base)

**Risk 2: Firebase Quota Exceeded**
- **Impact:** App stops working
- **Mitigation:** Monitor usage, upgrade to Blaze plan
- **Recovery:** Increase quotas immediately

**Risk 3: Live Stream Failure**
- **Impact:** No live content
- **Mitigation:** Configure backup stream URL
- **Recovery:** Switch to backup, notify users

---

## ✅ Launch Day Checklist

### Pre-Launch (Day Before)
- [ ] All features tested and working
- [ ] Content prepared and scheduled
- [ ] Live stream tested
- [ ] Backup procedures documented
- [ ] Support channels ready
- [ ] Monitoring tools configured
- [ ] Team briefed on launch plan

### Launch Day (Morning)
- [ ] Build final release (AAB)
- [ ] Upload to Play Console
- [ ] Submit for review
- [ ] Announce to test group
- [ ] Monitor Firebase Console
- [ ] Prepare launch communications

### Post-Launch (First Week)
- [ ] Daily monitoring of:
  - Crash reports
  - User feedback
  - Firebase usage
  - Live stream quality
- [ ] Address any critical issues within 24 hours
- [ ] Gather user feedback
- [ ] Plan first update

---

## 🎉 Success Criteria

### Technical Success
- ✅ < 1% crash rate
- ✅ < 5 second cold start time
- ✅ > 95% notification delivery rate
- ✅ < 2 second video start time

### User Success
- ✅ > 70% user retention after 7 days
- ✅ > 50% users watch live stream
- ✅ > 4.0 star rating (after 100+ reviews)
- ✅ < 1% negative reviews

### Business Success
- ✅ Meet user acquisition targets
- ✅ Maintain budget limits
- ✅ Positive community feedback
- ✅ Regular content updates

---

## 📞 Next Steps

**Choose your timeline:**
- **Need it fast?** → Option A (4 hours)
- **Want quality?** → Option B (3 days) ⭐ **RECOMMENDED**
- **Going enterprise?** → Option C (2 weeks)

**Start with:**
1. Read **DEPLOYMENT_CHECKLIST.md** thoroughly
2. Generate your release keystore
3. Configure live stream URL
4. Follow the timeline for your chosen option

**For admin help:**
- Quick start: **QUICK_START_ADMIN.md**
- Full guide: **ADMIN_SETUP_GUIDE.md**

**Questions?** Check **PROJECT_STATUS_REPORT.md** for detailed status.

---

**Good luck with your deployment! 🚀**
