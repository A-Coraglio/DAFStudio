import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/widgets/sport_filter_chips.dart';
import '../providers/tournaments_providers.dart';

const _levels = <({String? value, String label})>[
  (value: null, label: 'Todos'),
  (value: 'beginner', label: 'Principiante'),
  (value: 'intermediate', label: 'Intermedio'),
  (value: 'advanced', label: 'Avanzado'),
];

const _dates = <({TournamentDateFilter value, String label})>[
  (value: TournamentDateFilter.all, label: 'Cualquier fecha'),
  (value: TournamentDateFilter.today, label: 'Hoy'),
  (value: TournamentDateFilter.week, label: 'Esta semana'),
  (value: TournamentDateFilter.month, label: 'Este mes'),
];

/// Search field + sport / level / date filters for the tournaments screen.
class TournamentsFilterBar extends ConsumerStatefulWidget {
  const TournamentsFilterBar({super.key});

  @override
  ConsumerState<TournamentsFilterBar> createState() =>
      _TournamentsFilterBarState();
}

class _TournamentsFilterBarState extends ConsumerState<TournamentsFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(tournamentFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(TournamentFilter Function(TournamentFilter) change) {
    final notifier = ref.read(tournamentFilterProvider.notifier);
    notifier.state = change(notifier.state);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(tournamentFilterProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _controller,
            onChanged: (v) => _update((f) => f.copyWith(query: v)),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar torneo por nombre',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filter.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        _update((f) => f.copyWith(query: ''));
                      },
                    ),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SportFilterChips(
          selected: filter.sportId,
          onChanged: (id) => _update(
            (f) => id == null ? f.copyWith(clearSport: true) : f.copyWith(sportId: id),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final opt in _levels) ...[
                ChoiceChip(
                  label: Text(opt.label),
                  selected: filter.level == opt.value,
                  onSelected: (_) => _update(
                    (f) => opt.value == null
                        ? f.copyWith(clearLevel: true)
                        : f.copyWith(level: opt.value),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.only(right: 8),
                color: scheme.outlineVariant,
              ),
              for (final opt in _dates) ...[
                ChoiceChip(
                  label: Text(opt.label),
                  selected: filter.date == opt.value,
                  onSelected: (_) => _update((f) => f.copyWith(date: opt.value)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1),
      ],
    );
  }
}
