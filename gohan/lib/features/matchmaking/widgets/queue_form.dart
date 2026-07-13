import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/storage/mode_prefs.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../games/widgets/game_mode_picker.dart';
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
  String _mode = 'competitive';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sportId =
        ref.read(activeSportIdProvider) ??
        ref.read(myProfileProvider).valueOrNull?.favoriteSportId;
    // Restore the last matchmaking mode the user picked so repeat queuers
    // don't have to re-choose on every session.
    ModePrefs.readLastMatchmakingMode().then((m) {
      if (!mounted || m == null) return;
      setState(() => _mode = m);
    });
  }

  Future<void> _submit() async {
    if (_sportId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Elegí un deporte primero')));
      return;
    }

    setState(() => _loading = true);
    try {
      final (start, end) = _window.toRange();
      // Anchor the search at the device's location; fall back to the city
      // default when it's unavailable so matchmaking still works.
      final location = await ref.read(currentLocationProvider.future);
      await ref
          .read(matchmakingRepositoryProvider)
          .queue(
            QueueRequest(
              sportId: _sportId!,
              maxRadiusKm: _radiusKm,
              originLat: location?.lat ?? defaultOriginLat,
              originLon: location?.lon ?? defaultOriginLon,
              windowStart: start,
              windowEnd: end,
              mode: _mode,
            ),
          );
      await ModePrefs.writeLastMatchmakingMode(_mode);
      ref.invalidate(matchmakingStatusStreamProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The nav shell keeps this tab alive, so initState ran only once —
    // follow the home sport selector for as long as the form is idle.
    ref.listen(activeSportIdProvider, (_, next) {
      if (next != null && next != _sportId) {
        setState(() => _sportId = next);
      }
    });
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Jugar ya', style: Theme.of(context).textTheme.headlineSmall),
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
        Text('Modo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        GameModePicker(
          value: _mode,
          onChanged: (m) => setState(() => _mode = m),
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
