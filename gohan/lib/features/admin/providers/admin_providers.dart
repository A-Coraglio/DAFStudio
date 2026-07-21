import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/admin_repository.dart';
import '../data/admin_user.dart';
import '../data/audit_entry.dart';
import '../data/teacher_request_row.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiClientProvider));
});

/// True si la cuenta logueada es admin — gatea toda la UI de administración.
/// False mientras carga o si falla (nunca mostrar el panel "por las dudas").
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(myAccountProvider).valueOrNull?.isAdmin ?? false;
});

/// Buscador de usuarios del panel. Family por texto de búsqueda; autoDispose
/// para no retener resultados al salir del panel.
final adminUsersProvider = FutureProvider.autoDispose
    .family<List<AdminUser>, String>((ref, query) async {
      return ref.read(adminRepositoryProvider).listUsers(query: query);
    });

/// Solicitudes de profe pendientes de aprobación.
final adminTeacherRequestsProvider =
    FutureProvider.autoDispose<List<TeacherRequestRow>>((ref) async {
      return ref.read(adminRepositoryProvider).teacherRequests();
    });

final adminAuditProvider = FutureProvider.autoDispose<List<AuditEntry>>((
  ref,
) async {
  return ref.read(adminRepositoryProvider).audit();
});

final adminLogsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  return ref.read(adminRepositoryProvider).logs();
});
