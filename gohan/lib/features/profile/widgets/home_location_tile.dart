import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/location/location_service.dart';
import '../providers/profile_providers.dart';

/// "Ubicación de casa" tile: one tap saves the device's current location as
/// the user's home — classes and tournaments use it for distances.
class HomeLocationTile extends ConsumerStatefulWidget {
  const HomeLocationTile({super.key});

  @override
  ConsumerState<HomeLocationTile> createState() => _HomeLocationTileState();
}

class _HomeLocationTileState extends ConsumerState<HomeLocationTile> {
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final location = await LocationService.current();
      if (location == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No pudimos obtener tu ubicación — revisá los permisos.',
              ),
            ),
          );
        }
        return;
      }
      final account = await ref.read(myAccountProvider.future);
      await ref
          .read(profileRepositoryProvider)
          .setHomeLocation(account.id, lat: location.lat, lon: location.lon);
      ref.invalidate(myAccountProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación de casa guardada')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(myAccountProvider).valueOrNull;
    final hasHome = account?.hasHomeLocation ?? false;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.home_outlined),
        title: const Text('Ubicación de casa'),
        subtitle: Text(
          hasHome
              ? 'Configurada — se usa para las distancias'
              : 'Sin configurar — tocá para usar tu ubicación actual',
        ),
        trailing: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
        onTap: _busy ? null : _save,
      ),
    );
  }
}
