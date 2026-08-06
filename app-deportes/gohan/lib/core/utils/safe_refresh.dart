/// Wrapper for RefreshIndicator.onRefresh bodies.
///
/// If the refetch fails, the screen already shows its ErrorView through the
/// provider state — rethrowing here would only surface an unhandled
/// exception inside the RefreshIndicator. So: swallow, the UI tells the
/// story.
Future<void> safeRefresh(Future<void> Function() body) async {
  try {
    await body();
  } catch (_) {}
}
