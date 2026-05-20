import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../location/location_service.dart';

/// The device's current location, resolved once per session. `null` means
/// unavailable (services off / permission denied) — consumers fall back to
/// their no-location behavior. Invalidate to re-prompt after the user grants
/// permission from settings.
final currentLocationProvider = FutureProvider<UserLocation?>((ref) async {
  return LocationService.current();
});
