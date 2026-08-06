import 'package:flutter/material.dart';

/// Campos del alta de club: nombre, dirección y ciudad.
class ClubFormFields extends StatelessWidget {
  const ClubFormFields({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nombre del club'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressCtrl,
          decoration: const InputDecoration(labelText: 'Dirección'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: cityCtrl,
          decoration: const InputDecoration(labelText: 'Ciudad'),
        ),
      ],
    );
  }
}
