import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_view_state.dart';

class UninstallerDrawer extends StatelessWidget {
  const UninstallerDrawer({
    super.key,
    required this.selectedDestination,
    required this.formattedMemory,
    required this.freeBytes,
    required this.totalBytes,
    required this.onDestinationSelected,
    required this.onPrivacyPolicyTap,
    required this.onOtherAppsTap,
    required this.onAboutTap,
  });

  final UninstallerDestination selectedDestination;
  final String formattedMemory;
  final int freeBytes;
  final int totalBytes;
  final ValueChanged<UninstallerDestination> onDestinationSelected;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onOtherAppsTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * .88).clamp(0, 360).toDouble(),
      backgroundColor: context.color.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(
              formattedMemory: formattedMemory,
              freeBytes: freeBytes,
              totalBytes: totalBytes,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _SectionLabel('MANAGE'),
                  _DestinationTile(
                    icon: Icons.apps,
                    label: 'All Apps',
                    selected:
                        selectedDestination == UninstallerDestination.allApps,
                    onTap: () =>
                        onDestinationSelected(UninstallerDestination.allApps),
                  ),
                  _DestinationTile(
                    icon: Icons.history,
                    label: 'Recently Installed',
                    selected:
                        selectedDestination ==
                        UninstallerDestination.recentlyInstalled,
                    onTap: () => onDestinationSelected(
                      UninstallerDestination.recentlyInstalled,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  const _SectionLabel('INFORMATION'),
                  _DestinationTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: onPrivacyPolicyTap,
                  ),
                  _DestinationTile(
                    icon: Icons.storefront_outlined,
                    label: 'Other Apps',
                    onTap: onOtherAppsTap,
                  ),
                  _DestinationTile(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: onAboutTap,
                  ),
                ],
              ),
            ),
            const _AppVersion(),
          ],
        ),
      ),
    );
  }
}

class _AppVersion extends StatelessWidget {
  const _AppVersion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Uninstaller',
                style: TextStyle(
                  color: context.color.captionColor,
                  fontSize: 12,
                ),
              ),
              if (info != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Version ${info.version} (${info.buildNumber})',
                  style: TextStyle(
                    color: context.color.captionColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.formattedMemory,
    required this.freeBytes,
    required this.totalBytes,
  });

  final String formattedMemory;
  final int freeBytes;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.color.cardColor,
            context.color.accentColor.withOpacityPercent(8),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.color.accentColor.withOpacityPercent(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.color.backgroundColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: context.color.accentColor.withOpacityPercent(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.color.accentColor.withOpacityPercent(12),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Transform.scale(
                    scale: 1.85,
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Uninstaller',
                      maxLines: 2,
                      style: TextStyle(
                        color: context.color.titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Fast & simple app manager',
                      style: TextStyle(
                        color: context.color.bodyColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalBytes > 0) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Storage',
                  style: TextStyle(
                    color: context.color.bodyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  formattedMemory.replaceFirst('Free memory: ', ''),
                  style: TextStyle(
                    color: context.color.subTitleColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((totalBytes - freeBytes) / totalBytes).clamp(0, 1),
                minHeight: 6,
                backgroundColor: context.color.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.color.accentColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          color: context.color.captionColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        minTileHeight: 50,
        shape: const RoundedRectangleBorder(),
        selected: selected,
        selectedTileColor: context.color.accentColor.withOpacityPercent(14),
        leading: Icon(
          icon,
          color: selected
              ? context.color.accentColor
              : context.color.subTitleColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected
                ? context.color.accentColor
                : context.color.titleColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
