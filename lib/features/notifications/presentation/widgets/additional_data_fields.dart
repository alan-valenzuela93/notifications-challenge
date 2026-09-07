import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/additional_data_field.dart';

typedef _AdditionalDataControllers = ({
  int id,
  TextEditingController keyController,
  TextEditingController valueController,
});

class AdditionalDataFields extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final bool enabled;

  const AdditionalDataFields({
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  @override
  State<AdditionalDataFields> createState() => _AdditionalDataFieldsState();
}

class _AdditionalDataFieldsState extends State<AdditionalDataFields> {
  final ValueNotifier<List<_AdditionalDataControllers>> _entries =
      ValueNotifier<List<_AdditionalDataControllers>>(
        const <_AdditionalDataControllers>[],
      );
  int _nextId = 0;

  @override
  void dispose() {
    for (final _AdditionalDataControllers entry in _entries.value) {
      entry.keyController.dispose();
      entry.valueController.dispose();
    }
    _entries.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double spacing = AppResponsive.spacing(context, 12);

    return ValueListenableBuilder<List<_AdditionalDataControllers>>(
      valueListenable: _entries,
      builder:
          (
            BuildContext context,
            List<_AdditionalDataControllers> entries,
            Widget? child,
          ) {
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'Datos adicionales (opcional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: AppResponsive.spacing(context, 4)),
                    AppText(
                      'Agregá información opcional como identificadores o destinos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (entries.isEmpty) ...[
                      SizedBox(height: spacing),
                      AppText(
                        'No agregaste datos adicionales.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    for (int index = 0; index < entries.length; index++) ...[
                      SizedBox(height: spacing),
                      AdditionalDataField(
                        id: entries[index].id,
                        keyController: entries[index].keyController,
                        valueController: entries[index].valueController,
                        keyValidator: _validateKey,
                        valueValidator: _validateValue,
                        onChanged: (_) => _notifyChanged(),
                        onRemove: () => _removeEntry(entries[index].id),
                        enabled: widget.enabled,
                      ),
                      if (index < entries.length - 1) const Divider(),
                    ],
                    SizedBox(height: spacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        key: const Key('additional-data-add'),
                        onPressed: widget.enabled ? _addEntry : null,
                        icon: const Icon(Icons.add),
                        label: const AppText('Agregar dato'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  void _addEntry() {
    _entries.value = List<_AdditionalDataControllers>.unmodifiable(
      <_AdditionalDataControllers>[
        ..._entries.value,
        (
          id: _nextId++,
          keyController: TextEditingController(),
          valueController: TextEditingController(),
        ),
      ],
    );
    _notifyChanged();
  }

  void _removeEntry(int id) {
    final List<_AdditionalDataControllers> entries =
        List<_AdditionalDataControllers>.of(_entries.value);
    final int index = entries.indexWhere(
      (_AdditionalDataControllers entry) => entry.id == id,
    );
    if (index == -1) {
      return;
    }

    final _AdditionalDataControllers entry = entries.removeAt(index);
    _entries.value = List<_AdditionalDataControllers>.unmodifiable(entries);
    entry.keyController.dispose();
    entry.valueController.dispose();
    _notifyChanged();
  }

  String? _validateKey(String? value) {
    final String key = value?.trim() ?? '';
    if (key.isEmpty) {
      return 'Ingresá una clave.';
    }
    if (key.contains(RegExp(r'\s'))) {
      return 'La clave no puede contener espacios.';
    }

    final int duplicates = _entries.value.where((entry) {
      return entry.keyController.text.trim() == key;
    }).length;
    if (duplicates > 1) {
      return 'La clave no puede repetirse.';
    }
    return null;
  }

  String? _validateValue(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Ingresá un valor.';
    }
    return null;
  }

  void _notifyChanged() {
    if (_entries.value.isEmpty) {
      widget.onChanged(null);
      return;
    }

    widget.onChanged(<String, dynamic>{
      for (final _AdditionalDataControllers entry in _entries.value)
        if (entry.keyController.text.trim().isNotEmpty)
          entry.keyController.text.trim(): entry.valueController.text.trim(),
    });
  }
}
