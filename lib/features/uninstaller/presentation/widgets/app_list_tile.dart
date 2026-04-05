import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({super.key, required this.app});

  final AppInfoEntity app;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white24,
        backgroundImage:
            app.appIcon != null ? MemoryImage(app.appIcon!) : null,
        child: app.appIcon == null
            ? const Icon(Icons.android, color: Colors.white)
            : null,
      ),
      title: Text(
        '${app.appName} ${app.versionName}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${app.formattedSize}  •  ${DateFormat('EEE, d MMM yyyy').format(app.installDate)}',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
