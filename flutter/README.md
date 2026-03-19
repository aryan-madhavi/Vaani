# Vaani — Flutter App

Real-time bidirectional call translation. Users call each other by phone number and hear the other person speaking in their own language via live STT → Translation → TTS.

---

## First-Time Setup

```bash
cd flutter

# 1. Scaffold platform directories (if not already present)
flutter create . --project-name vaani --org com.carbonari

# 2. Add permissions to android/app/src/main/AndroidManifest.xml (inside <manifest>):
#    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
#    <uses-permission android:name="android.permission.INTERNET"/>
#    <uses-permission android:name="android.permission.READ_CONTACTS"/>

# 3. Generate Firebase config
dart pub global activate flutterfire_cli
flutterfire configure --project=autocalltranslate

# 4. Install packages + run code generation
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## Daily Commands

```bash
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8080   # Android emulator
flutter run --dart-define=BACKEND_URL=http://localhost:8080   # iOS simulator
flutter run --dart-define=BACKEND_URL=http://<LAN-IP>:8080    # physical device

dart run build_runner build --delete-conflicting-outputs      # after editing freezed models
flutter test
```

---

## Architecture

Feature-first under `lib/features/`:

```
features/
  auth/
    domain/app_user.dart              AppUser freezed model
    data/auth_repository.dart         Firebase Phone Auth + Firestore profile; FCM token storage
    presentation/login_screen.dart    OTP phone login; requests mic + FCM permissions after sign-in

  settings/
    domain/language_settings.dart     LanguageSettings freezed model
    data/language_repository.dart     SharedPreferences + Firestore sync
    presentation/language_settings_screen.dart

  call/
    domain/call_state.dart            CallPhase union, TranscriptEntry, CallSignal (freezed)
    domain/app_contact.dart           AppContact (device contact + Vaani UID)
    data/call_repository.dart         WebSocket, PCM16 mic capture, MP3 playback, speaker toggle
    data/contacts_provider.dart       Device contacts merged with phone_index Firestore lookups
    providers/call_providers.dart     CallController, TranscriptsNotifier, speakerProvider
    presentation/
      home_screen.dart                Contacts list, search, dial button
      outgoing_call_screen.dart       Ringing / waiting state
      incoming_call_screen.dart       Accept / decline
      active_call_screen.dart         Live transcripts + speaker toggle + hang up

core/
  constants.dart    BackendURL, kSupportedLanguages, FirestoreCollections, toE164()
  router.dart       GoRouter with auth + call phase redirects
  theme.dart        Light / dark theme
```

---

## Call Flow

1. **Caller** — `CallController.startCall(receiverUid)` → `POST /session` → writes `calls/{sessionId}` (status: `ringing`) → connects WebSocket → streams PCM16 audio
2. **Receiver** — `incomingCallProvider` Firestore stream fires → router shows `IncomingCallScreen`
3. **Receiver accepts** — `CallController.acceptCall(signal)` → connects WebSocket → backend fires `call_started` to both
4. **Active call** — both users stream PCM16; backend sends translated MP3 back; transcript events update UI
5. **Hang up** — `CallController.endCall()` → `DELETE /session` → Firestore `status: ended` → `CallPhase.ended` → idle after 2 s

---

## Riverpod Providers

| Provider | Type | Purpose |
|----------|------|---------|
| `authStateProvider` | `StreamProvider<User?>` | Firebase auth stream |
| `currentUserProvider` | `FutureProvider<AppUser?>` | Resolved AppUser from Firestore |
| `languageSettingsProvider` | `AsyncNotifierProvider` | User language (SharedPrefs + Firestore) |
| `callControllerProvider` | `AsyncNotifierProvider<CallPhase>` | Call lifecycle state machine |
| `incomingCallProvider(uid)` | `StreamProvider.family<CallSignal?>` | Firestore incoming call stream |
| `transcriptsProvider` | `NotifierProvider<List<TranscriptEntry>>` | Live transcript entries during call |
| `speakerProvider` | `StateProvider<bool>` | Speaker vs earpiece routing |
| `contactsProvider` | `FutureProvider<List<AppContact>>` | Merged device contacts + Vaani users |

---

## Code Generation

Files with `part '*.freezed.dart'` / `part '*.g.dart'` require build_runner after any edit:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Affected files:
- `lib/features/auth/domain/app_user.dart`
- `lib/features/settings/domain/language_settings.dart`
- `lib/features/call/domain/call_state.dart`

---

## Android Package

`com.carbonari.vaani` — package name used in `build.gradle.kts`, `AndroidManifest.xml`, `MainActivity.kt`, and Firebase console.

---

## Backend URL

Set at build time via `--dart-define=BACKEND_URL=<url>`. Defaults to `https://vaani-production.up.railway.app` in `lib/core/constants.dart`.

The WebSocket URL is derived automatically (`https` → `wss`, `http` → `ws`).
