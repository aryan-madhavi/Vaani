import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/data/auth_repository.dart';
import '../../settings/data/language_repository.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../data/contacts_provider.dart';
import '../domain/app_contact.dart';
import '../providers/call_providers.dart';
import 'contact_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  String _search = '';

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _storeFcmToken();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(contactsProvider);
    }
  }

  Future<void> _storeFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) { debugPrint('[fcm] getToken() returned null'); return; }
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;
      await ref.read(authRepositoryProvider).updateFcmToken(user.uid, token);
      debugPrint('[fcm] Token stored for ${user.uid}');
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        ref.read(authRepositoryProvider).updateFcmToken(user.uid, t);
      });
    } catch (e) { debugPrint('[fcm] Failed to store token: $e'); }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _call(AppContact contact) async {
    if (contact.uid == null) return;
    try {
      await ref.read(callControllerProvider.notifier).startCall(contact.uid!);
      final phase = ref.read(callControllerProvider);
      if (phase.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call failed: ${phase.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Call failed: $e')));
      }
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c             = AppColorScheme.of(context);
    final userAsync     = ref.watch(currentUserProvider);
    final settingsAsync = ref.watch(languageSettingsProvider);
    final contactsAsync = ref.watch(contactsProvider);

    final lang = settingsAsync.valueOrNull?.lang ?? '';
    final langName = lang.isEmpty
        ? '…'
        : kSupportedLanguages
            .firstWhere((l) => l.code == lang, orElse: () => kSupportedLanguages.first)
            .name;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.syne(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: 'Va'),
              TextSpan(text: '·', style: TextStyle(color: c.amber)),
              const TextSpan(text: 'ni'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_outlined),
            tooltip: 'My language',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── User info strip ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: userAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) => Row(
                children: [
                  Text(
                    user?.phoneNumber ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.textDim,
                        ),
                  ),
                  if (langName.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.amberDim,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        langName,
                        style: GoogleFonts.dmSans(
                          color: c.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts…',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                fillColor: c.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.amber, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),

          const SizedBox(height: 8),

          // ── Contacts list ─────────────────────────────────────────────────
          Expanded(
            child: contactsAsync.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: c.amber, strokeWidth: 2),
                    const SizedBox(height: 16),
                    Text(
                      'Loading contacts…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: c.textDim,
                          ),
                    ),
                  ],
                ),
              ),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.contacts_outlined, size: 48, color: c.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load contacts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.textDim,
                          ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(contactsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (contacts) => _ContactsList(
                contacts: contacts,
                search: _search,
                onCall: _call,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contacts list ──────────────────────────────────────────────────────────────

class _ContactsList extends StatelessWidget {
  const _ContactsList({
    required this.contacts,
    required this.search,
    required this.onCall,
  });

  final List<AppContact> contacts;
  final String search;
  final void Function(AppContact) onCall;

  @override
  Widget build(BuildContext context) {
    final filtered = search.isEmpty
        ? contacts
        : contacts
            .where((c) =>
                c.displayName.toLowerCase().contains(search) ||
                (c.phoneNumber?.contains(search) ?? false))
            .toList();

    final onApp    = filtered.where((c) => c.isOnApp).toList();
    final notOnApp = filtered.where((c) => !c.isOnApp).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No contacts found.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorScheme.of(context).textDim,
              ),
        ),
      );
    }

    final items = <Object>[];
    if (onApp.isNotEmpty) {
      items.add(_Section('On Vaani', onApp.length));
      items.addAll(onApp);
    }
    if (notOnApp.isNotEmpty) {
      items.add(const _Section('Invite to Vaani', null));
      items.addAll(notOnApp);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is _Section) return _SectionHeader(item);
        final contact = item as AppContact;
        return ContactTile(contact: contact, onCall: () => onCall(contact));
      },
    );
  }
}

class _Section {
  const _Section(this.title, this.count);
  final String title;
  final int? count;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.section);
  final _Section section;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: c.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            section.title.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: c.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (section.count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: c.amberDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${section.count}',
                style: GoogleFonts.dmSans(
                  color: c.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
