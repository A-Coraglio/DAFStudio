import 'package:geolocator/geolocator.dart';

/// A resolved device position. Plain value type so the rest of the app never
/// imports geolocator directly.
class UserLocation {
  const UserLocation(this.lat, this.lon);
  final double lat;
  final double lon;
}

/// Thin wrapper over geolocator. Every failure mode — location services off,
/// permission denied, hardware error — collapses to `null` so callers degrade
/// gracefully: no location simply means no distance / no geo anchor.
class LocationService {
  const LocationService._();

  static Future<UserLocation?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return UserLocation(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
