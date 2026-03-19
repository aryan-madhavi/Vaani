# Vaani

Real-time bidirectional call translation — two users on a phone call hear each other in their own language, instantly.

---

## How It Works

```
User A speaks (Marathi)
  → PCM16 audio → backend → STT → Translation → TTS → MP3 → User B hears (Hindi)

User B speaks (Hindi)
  → PCM16 audio → backend → STT → Translation → TTS → MP3 → User A hears (Marathi)
```

Both pipelines run simultaneously in full duplex. Transcripts of both sides appear live on screen during the call.

---

## Repository Layout

```
backend/                    Node.js translation server
  src/
    index.js                Bootstrap: Firebase Admin, Express, WebSocketServer
    routes.js               REST API (/health, /session CRUD)
    firebaseAuth.js         Firebase token verification
    sessionManager.js       In-memory session store with TTL timers
    translationPipeline.js  STT → Translate → TTS pipeline (one direction)
    wsHandler.js            WebSocket upgrade; wires bidirectional pipelines
  Dockerfile
  cloudbuild.yaml           Google Cloud Build CI/CD
  railway.json              Railway deployment config
  Deploy.md                 Full deployment guide (Cloud Run + Railway)

flutter/                    Flutter app (Android + iOS)
  lib/
    features/
      auth/                 Phone OTP login, user profile
      call/                 Call flow, WebSocket audio, transcripts, contacts
      settings/             Language picker
    core/
      constants.dart        Backend URL, supported languages, Firestore collections
      router.dart           GoRouter with auth + call state redirects
      theme.dart            Light / dark theme
```

---

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile app | Flutter · Riverpod · GoRouter · `record` · `audioplayers` |
| Auth | Firebase Phone Auth (OTP) |
| Signalling | Firestore (`calls/{sessionId}`) |
| Push | Firebase Cloud Messaging (FCM) |
| Transport | WebSocket (binary PCM16 in, binary MP3 out) |
| Backend | Node.js · Express · `ws` |
| STT | Google Cloud Speech-to-Text (latest_long, gRPC streaming) |
| Translation | Google Cloud Translation |
| TTS | Google Cloud Text-to-Speech (Chirp3-HD → Neural2-A → Standard-A fallback) |
| Deployment | Railway (primary) · Google Cloud Run (alternative) |

---

## Supported Languages

Marathi · Hindi · English (India) · English (US) · Tamil · Telugu · Kannada · Malayalam · Gujarati · Bengali · Punjabi · Odia

Add more in `flutter/lib/core/constants.dart` → `kSupportedLanguages`.

---

## Quick Start

### Backend

```bash
cd backend
npm install
export GOOGLE_APPLICATION_CREDENTIALS=./secrets/serviceAccountKey.json
export GOOGLE_CLOUD_PROJECT=autocalltranslate
npm run dev          # hot-reload on :8080
```

### Flutter app

```bash
cd flutter
flutter pub get
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8080   # Android emulator
flutter run --dart-define=BACKEND_URL=http://localhost:8080   # iOS simulator
```

See `backend/Deploy.md` for Railway / Cloud Run deployment.

---

## Firestore Structure

```
users/{uid}
  phoneNumber: string      E.164, e.g. "+919876543210"
  displayName: string
  lang: string             BCP-47, e.g. "mr-IN"
  isOnboarded: bool
  fcmToken: string

calls/{sessionId}
  callerUid: string
  receiverUid: string
  callerLang: string
  status: "ringing" | "active" | "ended"
  createdAt: Timestamp

phone_index/{e164}
  uid: string              Fast UID lookup by phone number
```

---

## GCP Project

`autocalltranslate` — Firebase project and GCP project are the same.
