import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/labels.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../../core/errors/error_snackbar.dart';
import '../../sports/widgets/sport_dropdown_field.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import 'name_field.dart';

const _levels = [null, 'beginner', 'intermediate', 'advanced'];

/// Bottom sheet to edit the player profile: name, level and favorite sport.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final PlayerProfile profile;

  static Future<void> show(BuildContext context, PlayerProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _firstCtrl = TextEditingController(text: widget.profile.firstName);
  late final _lastCtrl = TextEditingController(text: widget.profile.lastName);
  late String? _level = widget.profile.level;
  late int? _sportId = widget.profile.favoriteSportId;
  bool _loading = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateMyProfile(
            UpdatePlayerRequest(
              firstName: _firstCtrl.text.trim(),
              lastName: _lastCtrl.text.trim(),
              level: _level,
              favoriteSportId: _sportId,
            ),
          );
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Editar perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            NameField(controller: _firstCtrl, label: 'Nombre'),
            const SizedBox(height: 12),
            NameField(controller: _lastCtrl, label: 'Apellido'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _level,
              decoration: const InputDecoration(labelText: 'Nivel'),
              items: [
                for (final l in _levels)
                  DropdownMenuItem(value: l, child: Text(levelLabel(l))),
              ],
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: 12),
            SportDropdownField(
              value: _sportId,
              onChanged: (v) => setState(() => _sportId = v),
            ),
            const SizedBox(height: 20),
            PrimarySubmitButton(
              label: 'Guardar cambios',
              onPressed: _submit,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
