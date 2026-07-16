import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../errors/error_messages.dart';

/// Error state with an optional retry button. Pass the raw [error] and it
/// renders a friendly Spanish headline; the technical detail stays behind a
/// "Ver detalle" toggle (debug builds only). [message] overrides the headline.
class ErrorView extends StatefulWidget {
  const ErrorView({super.key, this.error, this.message, this.onRetry});

  final Object? error;
  final String? message;
  final VoidCallback? onRetry;

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  bool _showDetail = false;

  String get _headline =>
      widget.message ?? friendlyErrorMessage(widget.error);

  @override
  Widget build(BuildContext context) {
    final detail = kDebugMode ? widget.error?.toString() : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(_headline, textAlign: TextAlign.center),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: widget.onRetry,
                child: const Text('Reintentar'),
              ),
            ],
            if (detail != null && detail != _headline) ...[
              TextButton(
                onPressed: () => setState(() => _showDetail = !_showDetail),
                child: Text(_showDetail ? 'Ocultar detalle' : 'Ver detalle'),
              ),
              if (_showDetail)
                SelectableText(
                  detail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
