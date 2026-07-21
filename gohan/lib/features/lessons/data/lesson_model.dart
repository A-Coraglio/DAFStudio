/// A booked lesson with a teacher, as returned by /api/lessons/.
class Lesson {
  final int id;
  final int teacherId;
  final String teacherName;
  final int studentId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double totalPrice;

  const Lesson({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.studentId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as int,
    teacherId: json['teacher_id'] as int,
    teacherName: json['teacher_name'] as String,
    studentId: json['student_id'] as int,
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: DateTime.parse(json['end_time'] as String),
    status: json['status'] as String,
    totalPrice: (json['total_price'] as num).toDouble(),
  );

  bool get isCancelled => status == 'cancelled';

  bool get isPast => endTime.isBefore(DateTime.now());

  /// Still happening and still cancellable.
  bool get isActive => !isCancelled && !isPast;
}
