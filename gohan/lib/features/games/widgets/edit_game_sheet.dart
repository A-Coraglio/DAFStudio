import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/primary_submit_button.dart';
import '../../../core/errors/error_snackbar.dart';
import '../data/game.dart';
import '../providers/games_providers.dart';
import 'edit_game_fields.dart';

/// Organizer-only bottom sheet to tweak a live game's basics. Clearing the
/// date or the court sends an explicit null (borrado real en el backend).
class EditGameSheet extends ConsumerStatefulWidget {
  const EditGameSheet({super.key, required this.game});

  final Game game;

  static Future<void> show(BuildContext context, Game game) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditGameSheet(game: game),
    );
  }

  @override
  ConsumerState<EditGameSheet> createState() => _EditGameSheetState();
}

class _EditGameSheetState extends ConsumerState<EditGameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.game.name);
  late final _maxCtrl = TextEditingController(
    text: '${widget.game.maxPlayers}',
  );
  late String? _level = widget.game.level;
  late DateTime? _at = widget.game.scheduledAt;
  bool _removeCourt = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(gamesRepositoryProvider).update(
            widget.game.id,
            name: _nameCtrl.text.trim(),
            maxPlayers: int.parse(_maxCtrl.text.trim()),
            level: _level,
            scheduledAt: _at,
            clearSchedule: _at == null && widget.game.scheduledAt != null,
            clearCourt: _removeCourt,
          );
      ref.invalidate(gameByIdProvider(widget.game.id));
      ref.invalidate(feedGamesProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Partido actualizado')));
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
              'Editar partido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            EditGameFields(
              nameCtrl: _nameCtrl,
              maxCtrl: _maxCtrl,
              level: _level,
              onLevel: (v) => setState(() => _level = v),
              at: _at,
              onAt: (v) => setState(() => _at = v),
              hasCourt: widget.game.courtId != null,
              removeCourt: _removeCourt,
              onRemoveCourt: (v) => setState(() => _removeCourt = v),
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
