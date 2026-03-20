import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../data/language_repository.dart';
import '../../auth/data/auth_repository.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  /// When true, shows an onboarding header and a "Continue" button instead
  /// of the standard AppBar back arrow.  Called from /onboarding after
  /// first sign-in.
  const LanguageSettingsScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c            = AppColorScheme.of(context);
    final settingsAsync = ref.watch(languageSettingsProvider);

    return Scaffold(
      appBar: isOnboarding
          ? null
          : AppBar(
              title: Text(
                'My Language',
                style: GoogleFonts.syne(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
      body: Column(
        children: [
          // ── Onboarding header ──────────────────────────────────────────────
          if (isOnboarding) ...[
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: c.amberDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.amberGlow),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      size: 34,
                      color: c.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'What language do you speak?',
                    style: GoogleFonts.syne(
                      color: c.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick once — Vaani remembers it for every call.',
                    style: GoogleFonts.dmSans(
                      color: c.textDim,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: AppColorScheme.of(context).border),
            const SizedBox(height: 4),
          ],

          // ── Language list ──────────────────────────────────────────────────
          Expanded(
            child: settingsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: c.amber,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: GoogleFonts.dmSans(color: c.textDim),
                ),
              ),
              data: (settings) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: kSupportedLanguages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final option = kSupportedLanguages[i];
                  final selected = option.code == settings.lang;
                  return _LanguageTile(
                    option: option,
                    selected: selected,
                    onTap: () => ref
                        .read(languageSettingsProvider.notifier)
                        .setLang(option.code),
                  );
                },
              ),
            ),
          ),

          // ── Onboarding continue button ─────────────────────────────────────
          if (isOnboarding) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(
                  top: BorderSide(color: c.border),
                ),
              ),
              child: FilledButton(
                onPressed: () async {
                  final user = await ref.read(currentUserProvider.future);
                  if (user != null) {
                    await ref
                        .read(authRepositoryProvider)
                        .markOnboarded(user.uid);
                    ref.invalidate(currentUserProvider);
                  }
                  if (context.mounted) context.go('/');
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? c.amberDim : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? c.amberGlow : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Language initial badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? c.amber.withValues(alpha: 0.15) : c.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? c.amberGlow : c.border,
                ),
              ),
              child: Center(
                child: Text(
                  option.nativeName.isNotEmpty
                      ? option.nativeName[0].toUpperCase()
                      : option.name[0].toUpperCase(),
                  style: GoogleFonts.syne(
                    color: selected ? c.amber : c.textDim,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: GoogleFonts.dmSans(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.nativeName,
                    style: GoogleFonts.dmSans(
                      color: c.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: c.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: c.amber,
                  size: 16,
                ),
              )
            else
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
