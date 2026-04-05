import 'package:quick_uninstaller/core/services/app_info_service.dart';
import 'package:quick_uninstaller/core/services/device_service.dart';
import 'package:quick_uninstaller/core/services/launcher_service.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/core/utility/utility_export.dart';

Future<String> getEmailBody() async {
  final String reportInfo = await getDeviceInfo();
  final String currentVersion = await currentAppVersion;
  return '''
যে সমস্যাটি রিপোর্ট করছেন:

App Version: $currentVersion
ডিভাইস ইনফরমেশন:
${reportInfo.replaceAll(" ", ' ')}
''';
}

/// Sends an email asynchronously with the specified subject, body, and email address.
///
/// Example usage:
///
/// ```dart
/// await sendEmail(subject: 'Feedback', body: 'Hello, I have some feedback...');
/// ```
///
/// Rationale:
///
/// - provides a simple way to send emails asynchronously from within
/// your Flutter application.
/// - encapsulates the process of composing an email with the
/// specified subject, body, and recipient address,
/// abstracting away the complexities of
/// integrating with the device's default email client.
Future<void> sendEmail({
  String subject = "",
  String body = "",
  String email = reportEmailAddress,
}) async {
  String emailBody = body;
  if (emailBody.isEmpty) emailBody = await getEmailBody();

  final Map<String, String> mailContent = {
    'subject': subject,
    'body': emailBody,
  };
  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: mailContent,
  );
  final String urlString = uri.toString();
  await openUrl(url: urlString);
}
