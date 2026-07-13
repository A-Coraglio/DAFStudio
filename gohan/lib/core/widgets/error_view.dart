import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../http/api_client.dart';

/// Error state with an optional retry button. Pass the raw [error] and it
/// renders a human headline; the technical detail stays behind a "Ver
/// detalle" toggle. [message] overrides the derived headline.
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

  String get _headline {
    if (widget.message != null) return widget.message!;
    final e = widget.error;
    if (e is DioException) {
      return switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'No pudimos conectar con el servidor.\n'
              'Revisá tu conexión e intentá de nuevo.',
        _ => dioErrorMessage(e),
      };
    }
    return 'Algo salió mal.';
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.error?.toString();
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
