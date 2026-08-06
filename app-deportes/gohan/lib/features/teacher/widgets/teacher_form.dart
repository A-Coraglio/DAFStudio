import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/primary_submit_button.dart';
import '../../sports/providers/sports_providers.dart';
import 'teacher_form_data.dart';

/// Formulario de perfil de profe (alta y edición comparten esto):
/// bio, precio por hora, años de experiencia y deportes que enseña.
class TeacherForm extends ConsumerWidget {
  const TeacherForm({
    super.key,
    required this.data,
    required this.onToggleSport,
    required this.submitLabel,
    required this.loading,
    required this.onSubmit,
  });

  final TeacherFormData data;
  final ValueChanged<int> onToggleSport;
  final String submitLabel;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: data.bio,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
            hintText: 'Contales a tus alumnos qué enseñás y cómo',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: data.price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio por hora (\$)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: data.exp,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Años de experiencia (opcional)',
          ),
        ),
        const SizedBox(height: 12),
        Text('Deportes', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in sports)
              FilterChip(
                label: Text(s.name),
                selected: data.sportIds.contains(s.id),
                onSelected: (_) => onToggleSport(s.id),
              ),
          ],
        ),
        const SizedBox(height: 20),
        PrimarySubmitButton(
          label: submitLabel,
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
