import 'package:flutter/material.dart';
import 'package:quick_uninstaller/shared/components/error_widgets/custom_error_widget.dart';

class ErrorWidgetClass extends StatelessWidget {
  const ErrorWidgetClass({super.key, required this.errorDetails});

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Error',
      home: CustomErrorWidget(errorDetails: errorDetails),
    );
  }
}
