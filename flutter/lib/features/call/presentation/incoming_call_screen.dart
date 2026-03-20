import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../data/contacts_provider.dart';
import '../domain/call_state.dart';
import '../providers/call_providers.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key, required this.signal});

  final CallSignal signal;

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final signal = widget.signal;
    final controller = ref.read(callControllerProvider.notifier);
    final contacts    = ref.watch(contactsProvider).valueOrNull ?? [];
    final contact     = contacts.where((c) => c.uid == signal.callerUid).firstOrNull;
    final displayName = contact?.displayName.isNotEmpty == true
        ? contact!.displayName
        : signal.callerUid;
    final initial = displayName[0].toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // ── Incoming badge ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: c.mintDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.mint.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.mint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Incoming Vaani Call',
                    style: GoogleFonts.dmSans(
                      color: c.mint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Pulsing avatar ───────────────────────────────────────────────
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Transform.scale(
                      scale: _scale.value,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.mint.withValues(
                            alpha: _opacity.value * 0.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final t = (_pulse.value + 0.5) % 1.0;
                      final s = 1.0 + t * 0.5;
                      final o = (0.45 - t * 0.45).clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: s,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.mint.withValues(alpha: o * 0.25),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: c.mintDim,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c.mint.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.syne(
                          color: c.mint,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Caller info ──────────────────────────────────────────────────
            Text(
              displayName,
              style: GoogleFonts.syne(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'is calling you',
              style: GoogleFonts.dmSans(
                color: c.textDim,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.amberDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                signal.callerLang,
                style: GoogleFonts.dmSans(
                  color: c.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // ── Action buttons ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decline
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => controller.declineCall(signal.sessionId),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4B4B).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF4B4B).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Color(0xFFFF4B4B),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Decline',
                        style: GoogleFonts.dmSans(
                          color: c.textDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Accept
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => controller.acceptCall(signal),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: c.amberDim,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.amberGlow),
                            boxShadow: [
                              BoxShadow(
                                color: c.amber.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.call_rounded,
                            color: c.amber,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Accept',
                        style: GoogleFonts.dmSans(
                          color: c.textDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
