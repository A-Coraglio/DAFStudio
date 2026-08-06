import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_user.dart';
import '../providers/admin_providers.dart';

/// Selector de dueño para el alta de club: buscador + tap para elegir,
/// con opción de cambiar la elección.
class OwnerPicker extends ConsumerStatefulWidget {
  const OwnerPicker({
    super.key,
    required this.selected,
    required this.onPick,
    required this.onClear,
  });

  final AdminUser? selected;
  final ValueChanged<AdminUser> onPick;
  final VoidCallback onClear;

  @override
  ConsumerState<OwnerPicker> createState() => _OwnerPickerState();
}

class _OwnerPickerState extends ConsumerState<OwnerPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    if (selected != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person_outline),
        title: Text('Dueño: ${selected.displayName}'),
        subtitle: Text('@${selected.username}'),
        trailing: TextButton(
          onPressed: widget.onClear,
          child: const Text('Cambiar'),
        ),
      );
    }
    final results = ref.watch(adminUsersProvider(_query)).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBar(
          hintText: 'Buscar dueño (usuario, email o nombre)',
          leading: const Icon(Icons.search),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        const SizedBox(height: 8),
        if (results != null)
          ...results.where((u) => !u.isDeleted && !u.isBanned).take(5).map(
                (u) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline),
                  title: Text(u.displayName),
                  subtitle: Text('@${u.username} · ${u.email}'),
                  onTap: () => widget.onPick(u),
                ),
              ),
      ],
    );
  }
}
