import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Dev-only banner shown on the login screen when the app runs on a PHONE
/// pointing at localhost — there "localhost" is el teléfono mismo, así que
/// todos los requests fallan en silencio. Invisible en release, en web y
/// cuando la base URL ya fue overrideada.
class DebugBaseUrlNotice extends StatelessWidget {
  const DebugBaseUrlNotice({super.key});

  bool get _visible {
    if (!kDebugMode || kIsWeb) return false;
    final mobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return mobile && AppConfig.apiBaseUrl.contains('localhost');
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Backend en localhost: en un dispositivo físico eso apunta al '
        'teléfono y nada va a responder. Corré la app con '
        '--dart-define=API_BASE_URL=http://<ip-de-tu-pc>:8000',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onErrorContainer,
        ),
      ),
    );
  }
}
