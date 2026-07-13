import 'package:flutter/material.dart';

import '../../courts/data/court.dart';

/// Entrada al picker de canchas desde el form: muestra la selección actual
/// ("Sin cancha" por defecto) y abre la pantalla de elección al tocar.
class CourtPickerTile extends StatelessWidget {
  const CourtPickerTile({super.key, required this.court, required this.onTap});

  final Court? court;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(
          court == null ? Icons.add_location_alt_outlined : Icons.place,
          color: court == null ? scheme.onSurfaceVariant : scheme.primary,
        ),
        title: Text(court?.name ?? 'Elegir cancha'),
        subtitle: Text(
          court == null
              ? 'Opcional — se puede definir después'
              : court!.isPrivate
              ? 'Cancha privada'
              : 'Cancha de club',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
