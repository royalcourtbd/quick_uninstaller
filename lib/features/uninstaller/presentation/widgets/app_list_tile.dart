import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/utils/date_formatter.dart';
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
        backgroundColor: context.color.cardColor,
        backgroundImage:
            app.appIcon != null ? MemoryImage(app.appIcon!) : null,
        child: app.appIcon == null
            ? Icon(Icons.android, color: context.color.subTitleColor)
            : null,
      ),
      title: Text(
        '${app.appName} ${app.versionName}',
        style: TextStyle(
          color: context.color.titleColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${app.formattedSize}  •  ${getFormattedDate(app.installDate, format: 'EEE, d MMM yyyy')}',
        style: TextStyle(color: context.color.subTitleColor, fontSize: 13),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: context.color.subTitleColor),
        onPressed: () {},
      ),
    );
  }
}
