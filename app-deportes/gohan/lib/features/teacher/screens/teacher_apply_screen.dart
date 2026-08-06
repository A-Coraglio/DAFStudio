import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_snackbar.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_form.dart';
import '../widgets/teacher_form_data.dart';

/// Solicitud "quiero ser profe": el perfil propuesto queda pendiente hasta
/// que un admin lo apruebe.
class TeacherApplyScreen extends ConsumerStatefulWidget {
  const TeacherApplyScreen({super.key});

  @override
  ConsumerState<TeacherApplyScreen> createState() =>
      _TeacherApplyScreenState();
}

class _TeacherApplyScreenState extends ConsumerState<TeacherApplyScreen> {
  final _data = TeacherFormData();
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
      await ref.read(teacherRepositoryProvider).apply(
            bio: bio,
            pricePerHour: price,
            experienceYears: exp,
            sportIds: _data.sportIds.toList(),
          );
      ref.invalidate(myTeacherStatusProvider);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada! Un admin la va a revisar.'),
        ),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiero ser profe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherForm(
            data: _data,
            onToggleSport: (id) => setState(() => _data.toggleSport(id)),
            submitLabel: 'Enviar solicitud',
            loading: _busy,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}
