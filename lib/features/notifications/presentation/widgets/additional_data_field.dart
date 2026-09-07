import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text_form_field.dart';

class AdditionalDataField extends StatelessWidget {
  final int id;
  final TextEditingController keyController;
  final TextEditingController valueController;
  final FormFieldValidator<String> keyValidator;
  final FormFieldValidator<String> valueValidator;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;
  final bool enabled;

  const AdditionalDataField({
    required this.id,
    required this.keyController,
    required this.valueController,
    required this.keyValidator,
    required this.valueValidator,
    required this.onChanged,
    required this.onRemove,
    required this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 520;
        final Widget keyField = AppTextFormField(
          key: Key('additional-data-key-$id'),
          controller: keyController,
          labelText: 'Clave',
          hintText: 'orderId',
          textInputAction: TextInputAction.next,
          enabled: enabled,
          validator: keyValidator,
          onChanged: onChanged,
        );
        final Widget valueField = AppTextFormField(
          key: Key('additional-data-value-$id'),
          controller: valueController,
          labelText: 'Valor',
          hintText: '1234',
          textInputAction: TextInputAction.next,
          enabled: enabled,
          validator: valueValidator,
          onChanged: onChanged,
        );
        final Widget removeButton = IconButton(
          key: Key('additional-data-remove-$id'),
          tooltip: 'Eliminar dato adicional',
          onPressed: enabled ? onRemove : null,
          icon: const Icon(Icons.delete_outline),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              keyField,
              SizedBox(height: AppResponsive.spacing(context, 12)),
              valueField,
              Align(alignment: Alignment.centerRight, child: removeButton),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: keyField),
            SizedBox(width: AppResponsive.spacing(context, 12)),
            Expanded(child: valueField),
            SizedBox(width: AppResponsive.spacing(context, 4)),
            removeButton,
          ],
        );
      },
    );
  }
}
