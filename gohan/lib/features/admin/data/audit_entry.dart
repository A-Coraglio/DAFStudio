/// Una acción registrada en la auditoría de administración.
class AuditEntry {
  final int id;
  final String adminUsername;
  final String action;
  final String targetType;
  final int targetId;
  final String? detail;
  final DateTime createdAt;

  const AuditEntry({
    required this.id,
    required this.adminUsername,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.detail,
    required this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'] as int,
    adminUsername: json['admin_username'] as String,
    action: json['action'] as String,
    targetType: json['target_type'] as String,
    targetId: json['target_id'] as int,
    detail: json['detail'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  String get actionLabel => switch (action) {
    'ban' => 'Baneó',
    'unban' => 'Desbaneó',
    'delete_user' => 'Eliminó la cuenta de',
    'promote' => 'Hizo admin a',
    'demote' => 'Quitó el rol admin a',
    'cancel_game' => 'Canceló el partido',
    'kick_player' => 'Sacó a un jugador del partido',
    final other => other,
  };
}
