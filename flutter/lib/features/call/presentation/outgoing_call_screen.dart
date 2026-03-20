import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../domain/call_state.dart';
import '../providers/call_providers.dart';

class OutgoingCallScreen extends ConsumerStatefulWidget {
  const OutgoingCallScreen({super.key, required this.phase});

  final OutgoingPhase phase;

  @override
  ConsumerState<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends ConsumerState<OutgoingCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _scale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
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
    final initial = widget.phase.receiverUid.isNotEmpty
        ? widget.phase.receiverUid[0].toUpperCase()
        : '?';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Pulsing avatar ──────────────────────────────────────────────
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.amber.withValues(
                              alpha: _opacity.value * 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Inner pulse ring
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) {
                        final t = (_pulse.value + 0.5) % 1.0;
                        final s = 1.0 + t * 0.6;
                        final o = (0.5 - t * 0.5).clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: s,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.amber.withValues(alpha: o * 0.3),
                            ),
                          ),
                        );
                      },
                    ),
                    // Avatar
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: c.amberDim,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.amberGlow, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.syne(
                            color: c.amber,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Labels ──────────────────────────────────────────────────────
              Text(
                'Calling…',
                style: GoogleFonts.syne(
                  color: c.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  widget.phase.receiverUid,
                  style: GoogleFonts.dmSans(
                    color: c.textDim,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Waiting for them to pick up…',
                style: GoogleFonts.dmSans(
                  color: c.textMuted,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 64),

              // ── End call ────────────────────────────────────────────────────
              Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        ref.read(callControllerProvider.notifier).endCall(),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B4B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4B4B).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cancel',
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
      ),
    );
  }
}
