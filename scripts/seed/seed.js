import admin from 'firebase-admin';

function initializeAdmin() {
  try {
    if (process.env.FIRESTORE_EMULATOR_HOST) {
      // Initialize with default app for emulator usage (no creds needed)
      admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-project' });
      console.log('Using Firestore Emulator at', process.env.FIRESTORE_EMULATOR_HOST);
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      console.log('Initialized admin with application default credentials');
    } else {
      console.error('Missing credentials. Set GOOGLE_APPLICATION_CREDENTIALS or FIRESTORE_EMULATOR_HOST.');
      process.exit(1);
    }
  } catch (e) {
    console.error('Failed to initialize Firebase Admin:', e);
    process.exit(1);
  }
}

function pick<T>(value: T | undefined, fallback: T): T {
  return value === undefined || value === null ? fallback : value;
}

async function seed() {
  initializeAdmin();
  const db = admin.firestore();

  const userId = process.env.USER_ID || 'test-user';
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const todayEnd = new Date(todayStart.getTime() + 24 * 60 * 60 * 1000);

  // Users
  await db.collection('users').doc(userId).set({
    firstName: 'Jean',
    lastName: 'Dupont',
    email: 'jean@example.com',
    city: 'Paris',
    joinDate: now.toISOString(),
    preferences: {
      language: 'fr',
      darkMode: false,
      notifications: {
        liveServices: true,
        newSermons: true,
        events: true,
        prayerMeetings: true,
        testimonies: false,
      },
    },
    stats: {
      watchedPrograms: [],
      likedReels: [],
      totalWatchTime: 0,
      streakDays: 0,
    },
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
  });

  // Programs
  const programs = [
    {
      id: 'morning-service',
      title: 'Culte du Matin',
      description: 'Moment de louange et d\'adoration',
      category: 'culte',
      startTime: todayStart.toISOString(),
      endTime: new Date(todayStart.getTime() + 2 * 60 * 60 * 1000).toISOString(),
      thumbnailUrl: '',
      liveStreamUrl: '',
      isLive: true,
      isRecurring: true,
      tags: ['culte', 'louange'],
      host: {
        id: 'host1',
        name: 'Pasteur Martin',
        title: 'Pasteur Principal',
        avatarUrl: '',
      },
      metadata: {
        viewCount: 0,
        likeCount: 0,
        rating: 0.0,
        reminders: [],
        createdAt: now.toISOString(),
        updatedAt: now.toISOString(),
      },
    },
    {
      id: 'youth-meeting',
      title: 'Jeunesse en Action',
      description: 'Rencontre des jeunes',
      category: 'jeunesse',
      startTime: new Date(todayStart.getTime() + 5 * 60 * 60 * 1000).toISOString(),
      endTime: new Date(todayStart.getTime() + 6 * 60 * 60 * 1000).toISOString(),
      isLive: false,
      isRecurring: false,
      tags: ['jeunesse'],
      host: { id: 'host2', name: 'Soeur Marie', title: 'Leader Jeunesse', avatarUrl: '' },
      metadata: {
        viewCount: 0,
        likeCount: 0,
        rating: 0.0,
        reminders: [],
        createdAt: now.toISOString(),
        updatedAt: now.toISOString(),
      },
    },
  ];

  for (const p of programs) {
    await db.collection('programs').doc(p.id).set(p);
  }

  // Reels
  const reels = [
    {
      id: 'test-reel-1',
      title: 'Témoignage',
      description: 'Un témoignage puissant',
      videoUrl: 'https://storage.googleapis.com/your-bucket/reels/video1.mp4',
      thumbnailUrl: '',
      authorId: userId,
      authorName: 'Jean Dupont',
      authorAvatar: 'https://placehold.co/100x100',
      likes: [],
      likeCount: 0,
      comments: [],
      commentCount: 0,
      shares: 0,
      views: 0,
      duration: 30,
      tags: ['témoignage'],
      createdAt: now.toISOString(),
    },
  ];

  for (const r of reels) {
    await db.collection('reels').doc(r.id).set(r);
  }

  // Live stream
  await db.collection('liveStreams').doc('main').set({
    streamUrl: 'https://example.com/live.m3u8',
    backupUrl: '',
    isActive: true,
    quality: '1080p',
    bitrate: 5000,
    viewers: 0,
    startedAt: now.toISOString(),
  });

  // Notifications for the user
  const notifications = [
    {
      title: 'Service en direct',
      message: 'Le culte commence maintenant',
      type: 'live_service',
      read: false,
      createdAt: now.toISOString(),
    },
    {
      title: 'Nouveau sermon',
      message: 'Un nouveau sermon est disponible',
      type: 'new_sermon',
      read: false,
      createdAt: now.toISOString(),
    },
  ];

  for (const n of notifications) {
    await db.collection('notifications').add({ userId, ...n });
  }

  console.log('Seeding completed.');
  process.exit(0);
}

seed().catch((e) => {
  console.error('Seeding failed:', e);
  process.exit(1);
});

