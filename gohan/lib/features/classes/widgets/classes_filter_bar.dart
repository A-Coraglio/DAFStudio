import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/widgets/sport_filter_chips.dart';
import '../providers/classes_providers.dart';

const _prices = <({double? value, String label})>[
  (value: null, label: 'Cualquier precio'),
  (value: 7000, label: '≤ \$7000'),
  (value: 9000, label: '≤ \$9000'),
  (value: 12000, label: '≤ \$12000'),
];

/// Search field + sport / price filters for the classes screen.
class ClassesFilterBar extends ConsumerStatefulWidget {
  const ClassesFilterBar({super.key});

  @override
  ConsumerState<ClassesFilterBar> createState() => _ClassesFilterBarState();
}

class _ClassesFilterBarState extends ConsumerState<ClassesFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(classFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(ClassFilter Function(ClassFilter) change) {
    final notifier = ref.read(classFilterProvider.notifier);
    notifier.state = change(notifier.state);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(classFilterProvider);

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
              hintText: 'Buscar profe por nombre',
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
            (f) => id == null
                ? f.copyWith(clearSport: true)
                : f.copyWith(sportId: id),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final opt in _prices) ...[
                ChoiceChip(
                  label: Text(opt.label),
                  selected: filter.maxPrice == opt.value,
                  onSelected: (_) => _update(
                    (f) => opt.value == null
                        ? f.copyWith(clearMaxPrice: true)
                        : f.copyWith(maxPrice: opt.value),
                  ),
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
