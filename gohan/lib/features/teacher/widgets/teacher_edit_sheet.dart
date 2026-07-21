import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../classes/providers/classes_providers.dart';
import '../data/teacher_profile.dart';
import '../providers/teacher_providers.dart';
import 'teacher_form.dart';
import 'teacher_form_data.dart';

/// Sheet para editar el perfil de profe (bio, precio, experiencia, deportes).
class TeacherEditSheet extends ConsumerStatefulWidget {
  const TeacherEditSheet({super.key, required this.teacher});

  final TeacherProfile teacher;

  static Future<void> show(BuildContext context, TeacherProfile teacher) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TeacherEditSheet(teacher: teacher),
    );
  }

  @override
  ConsumerState<TeacherEditSheet> createState() => _TeacherEditSheetState();
}

class _TeacherEditSheetState extends ConsumerState<TeacherEditSheet> {
  late final _data = TeacherFormData.fromProfile(widget.teacher);
  bool _busy = false;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final values = _data.validate(context);
    if (values == null) return;
    final (bio, price, exp) = values;
    setState(() => _busy = true);
    try {
      await ref.read(teacherRepositoryProvider).updateMe(
            bio: bio,
            pricePerHour: price,
            experienceYears: exp,
            sportIds: _data.sportIds.toList(),
          );
      ref.invalidate(myTeacherStatusProvider);
      // El listado público de clases muestra estos datos.
      ref.invalidate(classesFetchProvider);
      ref.invalidate(recommendedClassesProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil de profe actualizado')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: TeacherForm(
          data: _data,
          onToggleSport: (id) => setState(() => _data.toggleSport(id)),
          submitLabel: 'Guardar cambios',
          loading: _busy,
          onSubmit: _submit,
        ),
      ),
    );
  }
}
