import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Notificación del browser (Notification API): pide permiso la primera vez
/// y después notifica aunque la pestaña esté en segundo plano. Todo fallo
/// (permiso denegado, API ausente) se traga — es un nice-to-have.
Future<void> showWebNotification(String title, String body) async {
  try {
    var permission = web.Notification.permission;
    if (permission == 'default') {
      permission = (await web.Notification.requestPermission().toDart).toDart;
    }
    if (permission != 'granted') return;
    web.Notification(title, web.NotificationOptions(body: body));
  } catch (_) {
    // Browser sin Notification API o bloqueada — seguimos sin notificar.
  }
}
