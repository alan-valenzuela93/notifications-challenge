import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationDeepLinkCard extends StatelessWidget {
  final String deepLink;
  final VoidCallback onProcess;

  const NotificationDeepLinkCard({
    required this.deepLink,
    required this.onProcess,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Deep link', style: theme.textTheme.titleMedium),
            SizedBox(height: AppResponsive.spacing(context, 12)),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppResponsive.spacing(context, 12)),
                child: SizedBox(
                  width: double.infinity,
                  child: AppText(deepLink, style: theme.textTheme.bodyMedium),
                ),
              ),
            ),
            SizedBox(height: AppResponsive.spacing(context, 12)),
            Tooltip(
              message: 'Validar y procesar el deep link',
              child: FilledButton.icon(
                onPressed: onProcess,
                icon: const Icon(Icons.open_in_new),
                label: const AppText('Procesar deep link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
