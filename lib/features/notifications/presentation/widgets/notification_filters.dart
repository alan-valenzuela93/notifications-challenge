import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';

class NotificationFilters extends StatefulWidget {
  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onSelected;

  const NotificationFilters({
    required this.selectedFilter,
    required this.onSelected,
    super.key,
  });

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends State<NotificationFilters> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _hasMoreFilters = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicator);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollIndicator)
      ..dispose();
    _hasMoreFilters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicator();
    });

    final ThemeData theme = Theme.of(context);
    final double horizontalPadding =
        AppResponsive.horizontalPadding(context) +
        AppResponsive.spacing(context, 4);
    final double indicatorWidth = AppResponsive.spacing(context, 48);

    return SizedBox(
      height: AppResponsive.filterBarHeight(context),
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppResponsive.spacing(context, 8),
            ),
            scrollDirection: Axis.horizontal,
            itemCount: NotificationFilter.values.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: AppResponsive.spacing(context, 8));
            },
            itemBuilder: (BuildContext context, int index) {
              final NotificationFilter filter =
                  NotificationFilter.values[index];

              return ChoiceChip(
                label: AppText(filter.label),
                selected: filter == widget.selectedFilter,
                onSelected: (bool selected) {
                  if (selected) {
                    widget.onSelected(filter);
                  }
                },
              );
            },
          ),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: indicatorWidth,
            child: IgnorePointer(
              child: ValueListenableBuilder<bool>(
                valueListenable: _hasMoreFilters,
                builder: (BuildContext context, bool hasMore, Widget? child) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: hasMore ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            theme.colorScheme.surface.withValues(alpha: 0),
                            theme.colorScheme.surface,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: AppResponsive.spacing(context, 6),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateScrollIndicator() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;
    if (!position.hasContentDimensions) {
      return;
    }

    final bool hasMoreFilters = position.extentAfter > 1;
    if (hasMoreFilters == _hasMoreFilters.value) {
      return;
    }

    _hasMoreFilters.value = hasMoreFilters;
  }
}
