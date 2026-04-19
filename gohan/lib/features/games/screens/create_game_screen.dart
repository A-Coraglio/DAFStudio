import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../courts/widgets/court_picker_field.dart';
import '../../sports/data/sport_model.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_dropdown_field.dart';
import '../data/create_game_request.dart';
import '../providers/games_providers.dart';
import '../widgets/game_datetime_picker.dart';
import '../widgets/game_level_picker.dart';
import '../widgets/game_mode_picker.dart';
import '../widgets/game_name_field.dart';
import '../widgets/max_players_field.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _maxPlayersCtrl = TextEditingController(text: '4');

  int? _sportId;
  int? _courtId;
  String _mode = 'casual';
  String? _level;
  DateTime? _scheduledAt;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Default the sport to the home's active sport when set.
    _sportId = ref.read(activeSportIdProvider);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _maxPlayersCtrl.dispose();
    super.dispose();
  }

  void _onSportChanged(int? id) {
    setState(() {
      _sportId = id;
      _courtId = null; // reset; courts are sport-specific
      _syncDefaultMaxPlayers(id);
    });
  }

  void _syncDefaultMaxPlayers(int? sportId) {
    if (sportId == null) return;
    final sports = ref.read(sportsListProvider).valueOrNull ?? const <Sport>[];
    for (final s in sports) {
      if (s.id == sportId) {
        _maxPlayersCtrl.text = (s.maxPlayersPerTeam * 2).toString();
        return;
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_sportId == null) return;

    setState(() => _loading = true);
    try {
      final game = await ref.read(gamesRepositoryProvider).create(
            CreateGameRequest(
              name: _nameCtrl.text.trim(),
              sportId: _sportId!,
              maxPlayers: int.parse(_maxPlayersCtrl.text.trim()),
              mode: _mode,
              courtId: _courtId,
              level: _level,
              scheduledAt: _scheduledAt,
            ),
          );
      ref.invalidate(feedGamesProvider);
      if (!mounted) return;
      context.go('/games/${game.id}');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear partido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GameNameField(controller: _nameCtrl),
            const SizedBox(height: 12),
            SportDropdownField(
              value: _sportId,
              onChanged: _onSportChanged,
              label: 'Deporte',
            ),
            const SizedBox(height: 12),
            Text('Modo', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            GameModePicker(
              value: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: 12),
            MaxPlayersField(controller: _maxPlayersCtrl),
            const SizedBox(height: 12),
            GameLevelPicker(
              value: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: 12),
            CourtPickerField(
              sportId: _sportId,
              value: _courtId,
              onChanged: (v) => setState(() => _courtId = v),
            ),
            const SizedBox(height: 12),
            GameDateTimePicker(
              value: _scheduledAt,
              onChanged: (v) => setState(() => _scheduledAt = v),
            ),
            const SizedBox(height: 24),
            PrimarySubmitButton(
              label: 'Crear partido',
              onPressed: _submit,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
