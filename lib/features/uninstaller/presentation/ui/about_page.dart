import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/logo.png', width: 96, height: 96),
                ),
                const SizedBox(height: 18),
                Text(
                  'Quick Uninstaller',
                  style: TextStyle(
                    color: context.color.titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    final version = info == null
                        ? 'Loading version…'
                        : 'Version ${info.version} (${info.buildNumber})';
                    return Text(
                      version,
                      style: TextStyle(color: context.color.subTitleColor),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.color.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'A lightweight Android app manager for reviewing installed apps, finding recently installed apps and quickly uninstalling apps you no longer need.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.color.bodyColor, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: context.color.cardColor,
            leading: Icon(
              Icons.description_outlined,
              color: context.color.accentColor,
            ),
            title: Text(
              'Open-source licenses',
              style: TextStyle(color: context.color.titleColor),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.color.subTitleColor,
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Quick Uninstaller',
              applicationIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/logo.png', width: 64, height: 64),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Developed by Amatullah Tech',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.color.captionColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
