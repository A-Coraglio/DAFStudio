import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/storage/mode_prefs.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../../core/errors/error_snackbar.dart';
import '../../courts/data/court.dart';
import '../../courts/screens/court_picker_screen.dart';
import '../../profile/providers/profile_providers.dart';
import '../../sports/data/sport_model.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_appbar_selector.dart';
import '../data/create_game_request.dart';
import '../data/sport_player_options.dart';
import '../providers/games_providers.dart';
import '../widgets/court_picker_tile.dart';
import '../widgets/game_datetime_picker.dart';
import '../widgets/game_mode_picker.dart';
import '../widgets/level_anchor_hint.dart';
import '../widgets/player_count_chips.dart';
import '../widgets/quick_date_chips.dart';

/// Crear partido, sin fricción: el deporte se elige arriba a la derecha
/// (ícono), el nombre se autogenera, el nivel sale del ranking del creador
/// y la cantidad de jugadores ofrece solo los valores válidos del deporte.
class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _sportId;
  int _maxPlayers = 4;
  String _mode = 'casual';
  DateTime? _scheduledAt;
  Court? _court;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sportId = ref.read(activeSportIdProvider);
    // El default de jugadores depende del deporte inicial.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = _sport();
      if (s != null && mounted) {
        setState(() => _maxPlayers = playerCountOptions(s).standard);
      }
    });
    ModePrefs.readLastCreateMode().then((m) {
      if (!mounted || m == null) return;
      setState(() => _mode = m);
    });
  }

  Sport? _sport() {
    final sports = ref.read(sportsListProvider).valueOrNull ?? const <Sport>[];
    for (final s in sports) {
      if (s.id == _sportId) return s;
    }
    return null;
  }

  /// "Fútbol 5 — vie 21 18:00" — el nombre ya no se pide: se autogenera.
  String _generatedName() {
    final s = _sport();
    if (s == null) return 'Partido';
    return _scheduledAt == null
        ? 'Partido de ${s.name}'
        : '${s.name} — ${formatSchedule(_scheduledAt)}';
  }

  void _onSportChanged(Sport sport) {
    setState(() {
      _sportId = sport.id;
      _court = null; // reset; las canchas son por deporte
      _maxPlayers = playerCountOptions(sport).standard;
    });
  }

  Future<void> _pickCourt() async {
    final selection = await CourtPickerScreen.push(
      context,
      sportId: _sportId,
      sportName: _sport()?.name,
      day: _scheduledAt ?? DateTime.now(),
    );
    if (selection != null && mounted) {
      setState(() => _court = selection.court);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_sportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elegí un deporte (arriba a la derecha).'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final game = await ref
          .read(gamesRepositoryProvider)
          .create(
            CreateGameRequest(
              name: _generatedName(),
              sportId: _sportId!,
              maxPlayers: _maxPlayers,
              mode: _mode,
              courtId: _court?.id,
              // El nivel ya no se elige: el ancla es el ranking del creador,
              // que el backend expone como organizer_ranking_points.
              level: null,
              scheduledAt: _scheduledAt,
            ),
          );
      await ModePrefs.writeLastCreateMode(_mode);
      ref.invalidate(feedGamesProvider);
      if (!mounted) return;
      context.go('/games/${game.id}');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sport = _sport();
    final counts = sport == null
        ? (options: const [2, 4], standard: 4)
        : playerCountOptions(sport);
    // The new game's level anchor is my ranking IN THE SELECTED SPORT.
    final myPoints = _sportId == null
        ? 1000
        : (ref.watch(mySportRankingProvider(_sportId!)).valueOrNull ?? 1000);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear partido'),
        actions: [
          SportAppBarSelector(value: _sportId, onChanged: _onSportChanged),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Modo', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            GameModePicker(
              value: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: 16),
            PlayerCountChips(
              key: ValueKey(_sportId),
              options: counts.options,
              value: _maxPlayers,
              onChanged: (n) => setState(() => _maxPlayers = n),
            ),
            const SizedBox(height: 16),
            Text('Cuándo', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            Text('Dónde', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            CourtPickerTile(court: _court, onTap: _pickCourt),
            const SizedBox(height: 16),
            LevelAnchorHint(points: myPoints),
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
