import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/location_provider.dart';

/// Warns that the search will anchor on the city-default coordinates because
/// the device location is unavailable (permission denied / service off).
/// Without this, users with location denied queued "en Buenos Aires" without
/// ever knowing why the matches were far away.
class LocationFallbackNotice extends ConsumerWidget {
  const LocationFallbackNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocationProvider);
    final missing = location.maybeWhen(
      data: (value) => value == null,
      orElse: () => false,
    );
    if (!missing) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, size: 20, color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin acceso a tu ubicación: buscamos cerca del centro de la '
              'ciudad. Permití la ubicación para resultados cerca tuyo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
