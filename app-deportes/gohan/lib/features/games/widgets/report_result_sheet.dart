import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/sport_sets.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../../core/errors/error_snackbar.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/games_providers.dart';
import 'score_counter_field.dart';

/// Modal sheet that lets a participant report their version of the final
/// score. Set-based sports (pádel, tenis, vóley) collect per-set scores; the
/// rest collect a single scoreline. The backend finalizes the game only when
/// all participants agree.
class ReportResultSheet extends ConsumerStatefulWidget {
  const ReportResultSheet({super.key, required this.gameId});

  final int gameId;

  static Future<void> show(BuildContext context, int gameId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportResultSheet(gameId: gameId),
    );
  }

  @override
  ConsumerState<ReportResultSheet> createState() => _ReportResultSheetState();
}

class _ReportResultSheetState extends ConsumerState<ReportResultSheet> {
  // Single-score mode.
  int _home = 0;
  int _away = 0;
  // Set mode.
  List<({int home, int away})> _sets = const [];
  bool _setsInit = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Seed the set rows if the game is already cached and is a set sport.
    final game = ref.read(gameByIdProvider(widget.gameId)).valueOrNull;
    if (game != null && isSetSport(game.sportName)) {
      _sets = const [(home: 0, away: 0), (home: 0, away: 0)];
      _setsInit = true;
    }
  }

  List<({int home, int away})> _validSets() =>
      _sets.where((s) => s.home != 0 || s.away != 0).toList();

  int get _homeSets => _validSets().where((s) => s.home > s.away).length;
  int get _awaySets => _validSets().where((s) => s.away > s.home).length;

  void _updateSet(int i, {int? home, int? away}) {
    final s = _sets[i];
    setState(() {
      _sets = [..._sets]..[i] = (home: home ?? s.home, away: away ?? s.away);
    });
  }

  Future<void> _submit(bool setSport) async {
    if (setSport && _validSets().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargá al menos un set')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(gamesRepositoryProvider);
      if (setSport) {
        await repo.reportResult(widget.gameId, sets: _validSets());
      } else {
        await repo.reportResult(widget.gameId, home: _home, away: _away);
      }
      ref.invalidate(gameByIdProvider(widget.gameId));
      ref.invalidate(myProfileProvider); // ranking may have changed
      ref.invalidate(myStatsProvider); // W/L/D may have changed
      ref.invalidate(myGamesProvider(null)); // history outcomes refresh
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado enviado. Esperando al resto del equipo.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the game wasn't cached at open time, seed the set rows when it lands.
    ref.listen(gameByIdProvider(widget.gameId), (_, next) {
      final g = next.valueOrNull;
      if (g != null && !_setsInit && isSetSport(g.sportName)) {
        setState(() {
          _sets = const [(home: 0, away: 0), (home: 0, away: 0)];
          _setsInit = true;
        });
      }
    });

    final game = ref.watch(gameByIdProvider(widget.gameId)).valueOrNull;
    final setSport = isSetSport(game?.sportName);
    final maxSets = maxSetsForSport(game?.sportName);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    // Scrollable: with several sets + keyboard on a short screen the column
    // used to overflow — the sheet is isScrollControlled, the content must
    // scroll too.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reportar resultado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Se cierra cuando todos los jugadores reportan lo mismo.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (setSport)
            _SetInputs(
              sets: _sets,
              homeSets: _homeSets,
              awaySets: _awaySets,
              onChanged: _updateSet,
              onAdd: _sets.length < maxSets
                  ? () =>
                      setState(() => _sets = [..._sets, (home: 0, away: 0)])
                  : null,
              onRemove: _sets.length > 1
                  ? (i) => setState(() => _sets = [..._sets]..removeAt(i))
                  : null,
            )
          else
            Row(
              children: [
                Expanded(
                  child: ScoreCounterField(
                    label: 'Local',
                    value: _home,
                    onChanged: (v) => setState(() => _home = v),
                  ),
                ),
                Expanded(
                  child: ScoreCounterField(
                    label: 'Visitante',
                    value: _away,
                    onChanged: (v) => setState(() => _away = v),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          PrimarySubmitButton(
            label: 'Enviar',
            onPressed: () => _submit(setSport),
            loading: _loading,
          ),
        ],
      ),
    );
  }
}

class _SetInputs extends StatelessWidget {
  const _SetInputs({
    required this.sets,
    required this.homeSets,
    required this.awaySets,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final List<({int home, int away})> sets;
  final int homeSets;
  final int awaySets;
  final void Function(int i, {int? home, int? away}) onChanged;
  final VoidCallback? onAdd;
  final void Function(int i)? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 52),
            Expanded(
              child: Text('Local',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text('Visitante',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < sets.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text('Set ${i + 1}',
                      style: theme.textTheme.labelMedium),
                ),
                Expanded(
                  child: _MiniStepper(
                    value: sets[i].home,
                    onChanged: (v) => onChanged(i, home: v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MiniStepper(
                    value: sets[i].away,
                    onChanged: (v) => onChanged(i, away: v),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove == null ? null : () => onRemove!(i),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Agregar set'),
            ),
            Text(
              'Sets: $homeSets - $awaySets',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
