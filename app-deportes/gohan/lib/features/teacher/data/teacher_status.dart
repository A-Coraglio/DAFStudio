import 'teacher_profile.dart';

/// Estado del "modo profesor" del usuario: si ya es profe, su perfil, y la
/// última solicitud (pending/approved/rejected) si hubo.
class TeacherStatus {
  final bool isTeacher;
  final TeacherProfile? teacher;
  final String? requestStatus;

  const TeacherStatus({
    required this.isTeacher,
    required this.teacher,
    required this.requestStatus,
  });

  factory TeacherStatus.fromJson(Map<String, dynamic> json) => TeacherStatus(
    isTeacher: json['is_teacher'] as bool? ?? false,
    teacher: json['teacher'] == null
        ? null
        : TeacherProfile.fromJson(json['teacher'] as Map<String, dynamic>),
    requestStatus:
        (json['request'] as Map<String, dynamic>?)?['status'] as String?,
  );

  bool get hasPendingRequest => !isTeacher && requestStatus == 'pending';
  bool get wasRejected => !isTeacher && requestStatus == 'rejected';
}
