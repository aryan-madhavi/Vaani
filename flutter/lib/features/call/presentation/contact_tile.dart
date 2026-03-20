import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme.dart';
import '../domain/app_contact.dart';

// Website URL
const _websiteUrl =
    'https://aryan-madhavi.github.io/Vaani/';

// Download links shown in the invite message.
const _androidUrl =
    'https://github.com/aryan-madhavi/Vaani/releases/latest/download/vaani.apk';

// Replace with TestFlight link once available.
// const _iosUrl = 'https://testflight.apple.com/join/XXXXXXXX';

const _inviteText =
    "Hey! I'm using Vaani for real-time voice translation on calls — "
    "it translates both sides of the call live so we can speak in our own languages.\n\n"
    "🌐 Website: $_websiteUrl\n"
    "📱 Android: $_androidUrl\n"
    "🍎 iOS: coming soon";

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    required this.onCall,
  });

  final AppContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final isOnApp = contact.isOnApp;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: _Avatar(contact: contact),
      title: Text(
        contact.displayName,
        style: GoogleFonts.dmSans(
          color: c.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: isOnApp
          ? Row(
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
                const SizedBox(width: 5),
                Text(
                  'On Vaani',
                  style: GoogleFonts.dmSans(
                    color: c.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Text(
              contact.phoneNumber ?? '',
              style: GoogleFonts.dmSans(
                color: c.textDim,
                fontSize: 12,
              ),
            ),
      trailing: isOnApp
          ? _CallButton(onCall: onCall)
          : _InviteButton(onInvite: () => _showInviteSheet(context)),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorScheme.of(context).border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Invite ${contact.displayName}',
                style: GoogleFonts.syne(
                  color: AppColorScheme.of(context).textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Let them know about Vaani',
                style: GoogleFonts.dmSans(
                  color: AppColorScheme.of(context).textDim,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _SheetOption(
                icon: Icons.sms_outlined,
                label: 'Send SMS',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  _sendSms(contact.phoneNumber);
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.share_outlined,
                label: 'More options…',
                color: AppColorScheme.of(context).textDim,
                onTap: () {
                  Navigator.pop(context);
                  Share.share(_inviteText);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendSms(String? phone) async {
    if (phone == null) return;
    final encoded = Uri.encodeComponent(_inviteText);
    final uri = Uri.parse('sms:$phone?body=$encoded');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.contact});
  final AppContact contact;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final initial = contact.displayName.isNotEmpty
        ? contact.displayName[0].toUpperCase()
        : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: contact.isOnApp ? c.amberDim : c.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: contact.isOnApp ? c.amberGlow : c.border,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.syne(
            color: contact.isOnApp ? c.amber : c.textDim,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.onCall});
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return GestureDetector(
      onTap: onCall,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.amberDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.amberGlow),
        ),
        child: Icon(Icons.call, color: c.amber, size: 20),
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onInvite});
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return GestureDetector(
      onTap: onInvite,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Text(
          'Invite',
          style: GoogleFonts.dmSans(
            color: c.textDim,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
