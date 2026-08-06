// showWebNotification(title, body): notificación del browser en web,
// no-op en mobile/desktop (conditional import).
export 'web_notification_stub.dart'
    if (dart.library.js_interop) 'web_notification_web.dart';
