import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../../core/storage/mode_prefs.dart';
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
import '../../../core/format/dates.dart';
import '../widgets/game_name_field.dart';
import '../widgets/max_players_field.dart';
import '../widgets/quick_date_chips.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
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
    // Restore the last mode the user picked when creating a game.
    ModePrefs.readLastCreateMode().then((m) {
      if (!mounted || m == null) return;
      setState(() => _mode = m);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nameCtrl.dispose();
    _maxPlayersCtrl.dispose();
    super.dispose();
  }

  /// "Fútbol 5 — vie 21 18:00": used as the game name when the user leaves
  /// the field empty. Null until a sport is picked.
  String? _suggestedName() {
    final sports = ref.read(sportsListProvider).valueOrNull ?? const <Sport>[];
    for (final s in sports) {
      if (s.id == _sportId) {
        return _scheduledAt == null
            ? 'Partido de ${s.name}'
            : '${s.name} — ${formatSchedule(_scheduledAt)}';
      }
    }
    return null;
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
    if (!_formKey.currentState!.validate()) {
      // The offending fields live at the top of the form.
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    if (_sportId == null) return;
    final name = _nameCtrl.text.trim().isEmpty
        ? _suggestedName()!
        : _nameCtrl.text.trim();

    setState(() => _loading = true);
    try {
      final game = await ref.read(gamesRepositoryProvider).create(
            CreateGameRequest(
              name: name,
              sportId: _sportId!,
              maxPlayers: int.parse(_maxPlayersCtrl.text.trim()),
              mode: _mode,
              courtId: _courtId,
              level: _level,
              scheduledAt: _scheduledAt,
            ),
          );
      await ModePrefs.writeLastCreateMode(_mode);
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
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            GameNameField(controller: _nameCtrl, suggestion: _suggestedName()),
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
            SizedBox(
              height: 40,
              child: QuickDateChips(
                value: _scheduledAt,
                onChanged: (v) => setState(() => _scheduledAt = v),
              ),
            ),
            const SizedBox(height: 8),
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
