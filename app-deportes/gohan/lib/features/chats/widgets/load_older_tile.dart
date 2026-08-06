import 'package:flutter/material.dart';

/// "Cargar mensajes anteriores" row pinned above the oldest message (i.e.
/// appended last in the reversed chat list).
class LoadOlderTile extends StatelessWidget {
  const LoadOlderTile({
    super.key,
    required this.loading,
    required this.onTap,
  });

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Cargar mensajes anteriores'),
              ),
      ),
    );
  }
}
