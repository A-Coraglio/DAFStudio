import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_user_tile.dart';

/// Panel de usuarios: buscador + acciones (ban, eliminar, rol admin).
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminUsersProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Usuario, email o nombre',
              leading: const Icon(Icons.search),
              onChanged: _onChanged,
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const TileListSkeleton(),
              error: (err, _) => ErrorView(
                error: err,
                onRetry: () => ref.invalidate(adminUsersProvider(_query)),
              ),
              data: (users) => users.isEmpty
                  ? const Center(child: Text('Sin resultados.'))
                  : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) => AdminUserTile(user: users[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
