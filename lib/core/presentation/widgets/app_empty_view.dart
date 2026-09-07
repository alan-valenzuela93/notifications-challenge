import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class AppEmptyView extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppEmptyView({required this.message, super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double padding = AppResponsive.spacing(context, 24);
        final double minimumHeight =
            constraints.hasBoundedHeight && constraints.maxHeight > padding * 2
            ? constraints.maxHeight - padding * 2
            : 0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minimumHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: AppResponsive.iconSize(context, 48),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: AppResponsive.spacing(context, 16)),
                  ],
                  AppText(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
