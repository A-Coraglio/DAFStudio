import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_search_query.dart';
import '../widgets/player_search_filters.dart';
import '../widgets/player_search_results.dart';

/// Discovery feed: search and filter other players, tap to open public profile.
/// The query input is debounced (300ms) so typing doesn't fire one request
/// per keystroke.
class PlayersDiscoveryScreen extends ConsumerStatefulWidget {
  const PlayersDiscoveryScreen({super.key});

  @override
  ConsumerState<PlayersDiscoveryScreen> createState() =>
      _PlayersDiscoveryScreenState();
}

class _PlayersDiscoveryScreenState
    extends ConsumerState<PlayersDiscoveryScreen> {
  PlayerSearchQuery _query = const PlayerSearchQuery();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = _query.copyWith(
            query: text.trim().isEmpty ? null : text.trim(),
            clearQuery: text.trim().isEmpty,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar jugadores')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Nombre o apellido',
              leading: const Icon(Icons.search),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlayerSearchFilters(
              query: _query,
              onChanged: (q) => setState(() => _query = q),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: PlayerSearchResults(query: _query)),
        ],
      ),
    );
  }
}
