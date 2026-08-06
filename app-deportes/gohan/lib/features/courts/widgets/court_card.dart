import 'package:flutter/material.dart';

import '../data/court.dart';
import 'court_slot_chips.dart';
import 'court_visual.dart';

/// Card de cancha en el picker: visual arriba, nombre + precio, y los
/// horarios ocupados del día elegido abajo.
class CourtCard extends StatelessWidget {
  const CourtCard({
    super.key,
    required this.court,
    required this.sportName,
    required this.day,
    required this.onTap,
  });

  final Court court;
  final String? sportName;
  final DateTime day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourtVisual(sportName: sportName, isIndoor: court.isIndoor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (court.pricePerHour > 0)
                        Text(
                          '\$${court.pricePerHour.toStringAsFixed(0)}/h',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (court.isPrivate)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CourtSlotChips(courtId: court.id, day: day),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
