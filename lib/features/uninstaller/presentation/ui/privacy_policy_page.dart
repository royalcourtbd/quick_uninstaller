import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = <(String, String)>[
    (
      'Information we access',
      'Quick Uninstaller accesses installed app information such as app name, package name, version, approximate APK size, install date, system-app status and app icon. It also reads total and available device storage to display storage information.',
    ),
    (
      'How information is used',
      'This information is used to show, search, sort and manage apps on your device. Installed-app information is processed locally and is not sold, rented or traded.',
    ),
    (
      'Local preferences',
      'Preferences such as your selected sort order may be stored on your device. You can remove this local data by clearing the app data or uninstalling Quick Uninstaller.',
    ),
    (
      'Uninstall actions',
      'Uninstall requests use Android’s standard confirmation flow. Quick Uninstaller cannot silently remove apps and does not bypass Android security controls.',
    ),
    (
      'Diagnostics and third-party services',
      'The app may use Firebase services for crash diagnostics and aggregated analytics. Installed app lists, contacts, SMS content, usernames and passwords are not intentionally collected for these services.',
    ),
    (
      'Data security and retention',
      'App-list processing remains on the device. Locally stored preferences remain until they are cleared or the app is uninstalled. Diagnostic information, when enabled, is handled under the applicable service provider policies.',
    ),
    (
      'Children’s privacy',
      'Quick Uninstaller is a general utility and is not designed to knowingly collect personal information from children.',
    ),
    (
      'Changes to this policy',
      'This policy may be updated when the app or its data practices change. The effective date shown here identifies the current version.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _PolicyHeader(),
          const SizedBox(height: 24),
          ..._sections.map(
            (section) => _PolicySection(title: section.$1, body: section.$2),
          ),
          Text(
            'Contact us',
            style: TextStyle(
              color: context.color.titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you have questions about this policy or our data practices, contact Amatullah Tech.',
            style: TextStyle(color: context.color.bodyColor, height: 1.6),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  launchUrl(Uri.parse('mailto:support@royalcourtbd.com')),
              icon: const Icon(Icons.email_outlined),
              label: const Text('support@royalcourtbd.com'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.color.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: context.color.accentColor,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'Your privacy matters',
            style: TextStyle(
              color: context.color.titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Effective: May 30, 2026',
            style: TextStyle(color: context.color.subTitleColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.color.titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(color: context.color.bodyColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
