import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../profile/providers/profile_providers.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_dropdown_field.dart';
import '../data/queue_request.dart';
import '../providers/matchmaking_providers.dart';
import 'radius_slider.dart';
import 'time_window_picker.dart';

/// Body of the matchmaking screen while the user is not in the queue.
class QueueForm extends ConsumerStatefulWidget {
  const QueueForm({super.key});

  @override
  ConsumerState<QueueForm> createState() => _QueueFormState();
}

class _QueueFormState extends ConsumerState<QueueForm> {
  int? _sportId;
  double _radiusKm = 5;
  TimeWindow _window = TimeWindow.now;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sportId = ref.read(activeSportIdProvider) ??
        ref.read(myProfileProvider).valueOrNull?.favoriteSportId;
  }

  Future<void> _submit() async {
    if (_sportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí un deporte primero')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final (start, end) = _window.toRange();
      await ref.read(matchmakingRepositoryProvider).queue(
            QueueRequest(
              sportId: _sportId!,
              maxRadiusKm: _radiusKm,
              originLat: defaultOriginLat,
              originLon: defaultOriginLon,
              windowStart: start,
              windowEnd: end,
            ),
          );
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Jugar ya',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Te emparejamos con gente de nivel similar cerca tuyo.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        SportDropdownField(
          value: _sportId,
          onChanged: (v) => setState(() => _sportId = v),
          label: 'Deporte',
        ),
        const SizedBox(height: 20),
        RadiusSlider(
          value: _radiusKm,
          onChanged: (v) => setState(() => _radiusKm = v),
        ),
        const SizedBox(height: 20),
        Text('Ventana horaria', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TimeWindowPicker(
          value: _window,
          onChanged: (v) => setState(() => _window = v),
        ),
        const SizedBox(height: 32),
        PrimarySubmitButton(
          label: 'Buscar partido',
          onPressed: _submit,
          loading: _loading,
        ),
      ],
    );
  }
}
