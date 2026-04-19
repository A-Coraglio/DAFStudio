/// App-wide configuration read from --dart-define flags.
///
/// When running the backend locally:
///   - Flutter web / desktop → http://localhost:8000
///   - Android emulator      → http://10.0.2.2:8000 (emulator loopback to host)
///   - iOS simulator         → http://localhost:8000
///   - Physical device       → `http://<your-lan-ip>:8000` (same WiFi)
///
/// Override with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
