import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/matchmaking_ticket.dart';
import '../providers/matchmaking_providers.dart';
import 'eta_hint.dart';
import 'queue_timer.dart';
import 'radar_pulse.dart';

/// Shown while the user is in queue (`waiting`). Spins a live timer +
/// cancel button.
class WaitingPanel extends ConsumerWidget {
  const WaitingPanel({
    super.key,
    required this.ticket,
    required this.estimatedWaitSeconds,
    required this.queueDepth,
  });

  final MatchmakingTicket ticket;
  final int? estimatedWaitSeconds;
  final int? queueDepth;

  String _sportName(WidgetRef ref) =>
      ref.watch(sportsListProvider).maybeWhen(
            data: (sports) {
              try {
                return sports.firstWhere((s) => s.id == ticket.sportId).name;
              } on StateError {
                return 'Deporte #${ticket.sportId}';
              }
            },
            orElse: () => '...',
          );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text('Buscando partido...',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadarPulse(child: QueueTimer(since: ticket.createdAt)),
          EtaHint(
            estimatedWaitSeconds: estimatedWaitSeconds,
            queueDepth: queueDepth,
          ),
          const SizedBox(height: 24),
          Text(
            '${_sportName(ref)} · hasta ${ticket.maxRadiusKm.round()} km',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          _CancelButton(),
        ],
      ),
    );
  }
}

class _CancelButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends ConsumerState<_CancelButton> {
  bool _loading = false;

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar búsqueda',
      message: '¿Dejar de buscar partido? Perdés tu lugar en la cola.',
      confirmLabel: 'Dejar de buscar',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref.read(matchmakingRepositoryProvider).cancel();
      ref.invalidate(matchmakingStatusStreamProvider);
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _cancel,
        icon: const Icon(Icons.close),
        label: Text(_loading ? 'Cancelando...' : 'Cancelar búsqueda'),
      ),
    );
  }
}
