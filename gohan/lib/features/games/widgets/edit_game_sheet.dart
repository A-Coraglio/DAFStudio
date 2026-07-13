import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../data/game.dart';
import '../providers/games_providers.dart';
import 'game_datetime_picker.dart';
import 'game_level_picker.dart';
import 'game_name_field.dart';
import 'max_players_field.dart';

/// Organizer-only bottom sheet to tweak a live game's basics.
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
      await ref
          .read(gamesRepositoryProvider)
          .update(
            widget.game.id,
            name: _nameCtrl.text.trim(),
            maxPlayers: int.parse(_maxCtrl.text.trim()),
            level: _level,
            scheduledAt: _at,
          );
      ref.invalidate(gameByIdProvider(widget.game.id));
      ref.invalidate(feedGamesProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Partido actualizado')));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
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
            GameNameField(controller: _nameCtrl),
            const SizedBox(height: 12),
            MaxPlayersField(controller: _maxCtrl),
            const SizedBox(height: 12),
            GameLevelPicker(
              value: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: 12),
            GameDateTimePicker(
              value: _at,
              onChanged: (v) => setState(() => _at = v),
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
