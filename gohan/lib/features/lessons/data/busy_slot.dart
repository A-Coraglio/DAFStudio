/// An occupied slot in a teacher's agenda — no student data on purpose.
class BusySlot {
  final DateTime start;
  final DateTime end;

  const BusySlot({required this.start, required this.end});

  factory BusySlot.fromJson(Map<String, dynamic> json) => BusySlot(
    start: DateTime.parse(json['start_time'] as String),
    end: DateTime.parse(json['end_time'] as String),
  );
}
