import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../data/call_repository.dart';
import '../domain/call_state.dart';
import '../providers/call_providers.dart';
import '../../settings/data/language_repository.dart';

class ActiveCallScreen extends ConsumerWidget {
  const ActiveCallScreen({super.key, required this.phase});

  final ActivePhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c          = AppColorScheme.of(context);
    final transcripts = ref.watch(transcriptsProvider);
    final myLang     = ref.watch(languageSettingsProvider).valueOrNull?.lang ?? '';
    final isSpeaker  = ref.watch(speakerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.syne(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
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
          // Speaker toggle
          IconButton(
            icon: Icon(
              isSpeaker ? Icons.volume_up_rounded : Icons.hearing_rounded,
              color: c.textDim,
              size: 22,
            ),
            tooltip: isSpeaker ? 'Switch to earpiece' : 'Switch to speaker',
            onPressed: () async {
              final next = !isSpeaker;
              ref.read(speakerProvider.notifier).state = next;
              await ref.read(callRepositoryProvider).setSpeaker(next);
            },
          ),
          // End call
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.call_end_rounded,
                color: Color(0xFFFF4B4B),
                size: 22,
              ),
              tooltip: 'End call',
              onPressed: () =>
                  ref.read(callControllerProvider.notifier).endCall(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Live status bar ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                _LiveDot(),
                const SizedBox(width: 8),
                Text(
                  'Live translation active',
                  style: GoogleFonts.dmSans(
                    color: c.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (myLang.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.amberDim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      myLang,
                      style: GoogleFonts.dmSans(
                        color: c.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Transcript list ────────────────────────────────────────────────
          Expanded(
            child: transcripts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: c.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border),
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            color: c.textMuted,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Start speaking…',
                          style: GoogleFonts.dmSans(
                            color: c.textDim,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your words will appear here in real time',
                          style: GoogleFonts.dmSans(
                            color: c.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    reverse: true,
                    itemCount: transcripts.length,
                    itemBuilder: (context, i) {
                      final entry = transcripts[transcripts.length - 1 - i];
                      return _TranscriptBubble(
                        entry: entry,
                        isMine: !entry.isTranslation,
                      );
                    },
                  ),
          ),

          // ── End call bar ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(
                top: BorderSide(color: c.border),
              ),
            ),
            child: GestureDetector(
              onTap: () => ref.read(callControllerProvider.notifier).endCall(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFF4B4B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.call_end_rounded,
                      color: Color(0xFFFF4B4B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'End Call',
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFFF4B4B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live dot (blinking) ────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return AnimatedBuilder(
      animation: _fade,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: c.mint,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Transcript bubble ──────────────────────────────────────────────────────────

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.entry, required this.isMine});

  final TranscriptEntry entry;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    // isMine = my own speech (amber, right-aligned)
    // !isMine = translated partner speech (mint, left-aligned)
    final bgColor    = isMine ? c.amberDim : c.mintDim;
    final borderColor = isMine
        ? c.amber.withValues(alpha: 0.25)
        : c.mint.withValues(alpha: 0.25);
    final textColor  = isMine ? c.amber : c.mint;
    final labelColor = isMine
        ? c.amber.withValues(alpha: 0.5)
        : c.mint.withValues(alpha: 0.5);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.isTranslation)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'Translated · ${entry.lang}',
                  style: GoogleFonts.dmSans(
                    color: labelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            Text(
              entry.text,
              style: GoogleFonts.dmSans(
                color: entry.isFinal
                    ? textColor
                    : textColor.withValues(alpha: 0.6),
                fontSize: 14,
                fontStyle:
                    entry.isFinal ? FontStyle.normal : FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
