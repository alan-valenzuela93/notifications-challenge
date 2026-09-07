import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_loading_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationListFooter extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLoadMore;

  const NotificationListFooter({
    super.key,
    required this.isLoading,
    required this.onLoadMore,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 20)),
        child: Center(
          child: SizedBox.square(
            dimension: AppResponsive.iconSize(context, 24),
            child: const AppLoadingView(),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
        child: Column(
          children: [
            AppText(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: AppResponsive.spacing(context, 8)),
            TextButton(
              onPressed: onLoadMore,
              child: const AppText('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
      child: Center(
        child: FilledButton.tonalIcon(
          key: const Key('notifications-load-more'),
          onPressed: onLoadMore,
          icon: const Icon(Icons.expand_more),
          label: const AppText('Cargar más'),
        ),
      ),
    );
  }
}
