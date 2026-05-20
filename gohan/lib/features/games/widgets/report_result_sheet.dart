import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/games_providers.dart';
import 'score_counter_field.dart';

/// Modal sheet that lets a participant report their version of the final
/// score. Backend finalizes the game only when all participants agree.
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
  int _home = 0;
  int _away = 0;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(gamesRepositoryProvider).reportResult(
            widget.gameId,
            home: _home,
            away: _away,
          );
      ref.invalidate(gameByIdProvider(widget.gameId));
      ref.invalidate(myProfileProvider); // ranking may have changed
      ref.invalidate(myStatsProvider); // W/L/D may have changed
      ref.invalidate(myGamesProvider(null)); // history list outcomes refresh
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado enviado. Esperando al resto del equipo.'),
        ),
      );
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
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
          const SizedBox(height: 24),
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
            onPressed: _submit,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}
