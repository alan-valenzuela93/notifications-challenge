import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationDataEntry extends StatelessWidget {
  final String label;
  final Object? value;

  const NotificationDataEntry({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppResponsive.spacing(context, 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, style: theme.textTheme.labelLarge),
          SizedBox(height: AppResponsive.spacing(context, 4)),
          AppText(_formattedValue, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  String get _formattedValue {
    if (value == null) {
      return 'null';
    }
    if (value is String || value is num || value is bool) {
      return value.toString();
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      return value.toString();
    }
  }
}
