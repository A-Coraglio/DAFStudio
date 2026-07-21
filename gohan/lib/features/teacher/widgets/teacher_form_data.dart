import 'package:flutter/material.dart';

import '../data/teacher_profile.dart';

/// Estado compartido del formulario de profe (alta y edición): controllers,
/// deportes elegidos y la validación con su snack.
class TeacherFormData {
  TeacherFormData();

  TeacherFormData.fromProfile(TeacherProfile p) {
    bio.text = p.bio ?? '';
    price.text = p.pricePerHour.toStringAsFixed(0);
    exp.text = p.experienceYears?.toString() ?? '';
    sportIds.addAll(p.sportIds);
  }

  final bio = TextEditingController();
  final price = TextEditingController();
  final exp = TextEditingController();
  final Set<int> sportIds = {};

  void toggleSport(int id) {
    sportIds.contains(id) ? sportIds.remove(id) : sportIds.add(id);
  }

  /// (bio, precio, experiencia) o null mostrando el snack de error.
  (String, double, int?)? validate(BuildContext context) {
    final parsedPrice =
        double.tryParse(price.text.trim().replaceAll(',', '.'));
    if (bio.text.trim().isEmpty || parsedPrice == null || sportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá bio, precio y al menos un deporte.'),
        ),
      );
      return null;
    }
    return (bio.text.trim(), parsedPrice, int.tryParse(exp.text.trim()));
  }

  void dispose() {
    bio.dispose();
    price.dispose();
    exp.dispose();
  }
}
