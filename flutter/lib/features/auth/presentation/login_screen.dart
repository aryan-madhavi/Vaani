import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../data/auth_repository.dart';

/// Two-step phone auth screen.
///
/// Step 1 — phone number entry → tapping "Send OTP" calls Firebase
///           verifyPhoneNumber and advances to step 2.
/// Step 2 — 6-digit OTP entry → tapping "Verify" calls signInWithCredential.
///           On Android the SMS Retriever API may auto-fill and skip step 2.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool _loading    = false;
  String? _error;

  bool _otpSent          = false;
  String? _verificationId;
  int? _resendToken;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    await AudioRecorder().hasPermission();
    await FirebaseMessaging.instance.requestPermission();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final phone = toE164(_phoneCtrl.text.trim());
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() { _loading = true; _error = null; });

    await ref.read(authRepositoryProvider).sendOtp(
      phone,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken    = resendToken;
          _otpSent        = true;
          _loading        = false;
        });
      },
      onFailed: (e) {
        if (!mounted) return;
        setState(() { _error = e.message ?? 'Failed to send OTP'; _loading = false; });
      },
      onAutoVerified: (credential) async {
        if (!mounted) return;
        setState(() => _loading = true);
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _requestPermissions();
        } catch (e) {
          if (mounted) setState(() => _error = e.toString());
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      },
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authRepositoryProvider).confirmOtp(_verificationId!, code);
      await _requestPermissions();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Invalid code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c  = AppColorScheme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Brand ─────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: c.amberDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.amberGlow),
                      ),
                      child: Icon(
                        Icons.translate_rounded,
                        size: 36,
                        color: c.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.syne(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        const TextSpan(text: 'Vaa'),
                        TextSpan(text: '·', style: TextStyle(color: c.amber)),
                        const TextSpan(text: 'ni'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Call anyone. Speak your language.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.textDim,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  // ── Error ─────────────────────────────────────────────────
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]
                  else ...[
                    const SizedBox(height: 48),
                  ],
                  
                  // ── Card ──────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.border),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _otpSent
                          ? _OtpStep(
                              key: const ValueKey('otp'),
                              phone: toE164(_phoneCtrl.text.trim()),
                              ctrl: _otpCtrl,
                              loading: _loading,
                              resendToken: _resendToken,
                              verificationId: _verificationId,
                              onVerify: _verifyOtp,
                              onChangeNumber: () => setState(() {
                                _otpSent = false;
                                _otpCtrl.clear();
                                _error   = null;
                              }),
                              onResend: () async {
                                final phone = toE164(_phoneCtrl.text.trim());
                                setState(() { _loading = true; _error = null; });
                                await ref.read(authRepositoryProvider).sendOtp(
                                  phone,
                                  resendToken: _resendToken,
                                  onCodeSent: (vid, rt) {
                                    if (!mounted) return;
                                    setState(() {
                                      _verificationId = vid;
                                      _resendToken    = rt;
                                      _loading        = false;
                                    });
                                  },
                                  onFailed: (e) {
                                    if (!mounted) return;
                                    setState(() {
                                      _error   = e.message ?? 'Failed to resend';
                                      _loading = false;
                                    });
                                  },
                                );
                              },
                            )
                          : _PhoneStep(
                              key: const ValueKey('phone'),
                              ctrl: _phoneCtrl,
                              loading: _loading,
                              onSend: _sendOtp,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step widgets ──────────────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({super.key, required this.ctrl, required this.loading, required this.onSend});

  final TextEditingController ctrl;
  final bool loading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter your mobile number',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'We\'ll send a one-time code to verify',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textDim),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
          style: GoogleFonts.dmSans(fontSize: 16, color: c.textPrimary, letterSpacing: 0.5),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '+91 98765 43210',
          ),
          onSubmitted: (_) => loading ? null : onSend(),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onSend,
          child: loading
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: c.bg),
                )
              : const Text('Send OTP'),
        ),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    super.key,
    required this.phone,
    required this.ctrl,
    required this.loading,
    required this.resendToken,
    required this.verificationId,
    required this.onVerify,
    required this.onChangeNumber,
    required this.onResend,
  });

  final String phone;
  final TextEditingController ctrl;
  final bool loading;
  final int? resendToken;
  final String? verificationId;
  final VoidCallback onVerify;
  final VoidCallback onChangeNumber;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.amberDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'OTP Sent',
                style: GoogleFonts.dmSans(
                  color: c.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the code sent to',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          phone,
          style: GoogleFonts.dmSans(
            color: c.amber,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
            letterSpacing: 8,
          ),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '——————',
            counterText: '',
          ),
          onSubmitted: (_) => loading ? null : onVerify(),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onVerify,
          child: loading
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: c.bg),
                )
              : const Text('Verify & Continue'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: loading ? null : onChangeNumber,
              child: const Text('Change number'),
            ),
            TextButton(
              onPressed: loading ? null : onResend,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ],
    );
  }
}
