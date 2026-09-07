abstract final class CreateNotificationFormValidators {
  static const int titleMaxLength = 120;
  static const int bodyMaxLength = 500;

  static String? recipientId(String? value) {
    final String recipient = value?.trim() ?? '';
    if (recipient.isEmpty) {
      return 'Ingresá un destinatario.';
    }
    if (recipient.contains(RegExp(r'\s'))) {
      return 'El identificador no puede contener espacios.';
    }
    return null;
  }

  static String? title(String? value) {
    final String title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Ingresá un título.';
    }
    if (title.length > titleMaxLength) {
      return 'El título no puede superar los $titleMaxLength caracteres.';
    }
    return null;
  }

  static String? body(String? value) {
    final String body = value?.trim() ?? '';
    if (body.isEmpty) {
      return 'Ingresá el cuerpo de la notificación.';
    }
    if (body.length > bodyMaxLength) {
      return 'El cuerpo no puede superar los $bodyMaxLength caracteres.';
    }
    return null;
  }
}
