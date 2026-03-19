import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'features/call/providers/call_providers.dart';
import 'features/settings/data/language_repository.dart';
import 'firebase_options.dart';

/// Background FCM handler — must be a top-level function.
/// Called when a data-only message arrives while the app is in background/terminated.
/// With a notification block in the FCM payload the OS shows the notification
/// automatically, so we only need Firebase to be initialized here.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create the Android notification channel for incoming calls.
  // Must match the channelId sent in the FCM payload from the backend.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // App launched by tapping an FCM notification (terminated state).
  // The Firestore incomingCallProvider stream will detect the ringing call
  // doc and the router will redirect to /call/incoming automatically once
  // Firebase auth restores the session — no manual navigation needed.
  await FirebaseMessaging.instance.getInitialMessage();

  // App brought to foreground by tapping an FCM notification (background state).
  // Same as above — the Firestore stream is already active, so the router
  // will have already redirected; nothing extra to do on tap.
  FirebaseMessaging.onMessageOpenedApp.listen((_) {
    // Navigation is driven by incomingCallProvider — no action needed here.
  });

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CallTranslateApp(),
    ),
  );
}

class CallTranslateApp extends ConsumerWidget {
  const CallTranslateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Listen here — this widget is always mounted regardless of which route
    // is active. Use rootNavigatorKey.currentContext so the dialog is shown
    // on top of whatever screen is currently visible, and only after the
    // current navigation frame has fully settled.
    ref.listen<String?>(callEndReasonProvider, (_, reason) {
      if (reason == null) return;
      ref.read(callEndReasonProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx == null) return;
        showDialog<void>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: const Text('Call Ended'),
            content: Text(reason),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    });

    return MaterialApp.router(
      title: 'Vaani',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
