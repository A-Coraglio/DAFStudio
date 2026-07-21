import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../../../core/widgets/stat_chip.dart';
import '../data/class_model.dart';
import 'class_header.dart';

/// Header card of the class detail: teacher, sports taught, bio, price and
/// experience.
class ClassInfoCard extends StatelessWidget {
  const ClassInfoCard({super.key, required this.offering});

  final ClassOffering offering;

  @override
  Widget build(BuildContext context) {
    final bio = offering.bio;
    final distance = distanceLabel(offering.distanceKm);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClassHeader(offering: offering),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                StatChip(
                  icon: Icons.payments_outlined,
                  label: '\$${offering.pricePerHour.round()}/h',
                ),
                if (offering.experienceYears != null)
                  StatChip(
                    icon: Icons.workspace_premium_outlined,
                    label: '${offering.experienceYears} años de experiencia',
                  ),
                if (distance != null)
                  StatChip(icon: Icons.place_outlined, label: distance),
              ],
            ),
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(bio, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
