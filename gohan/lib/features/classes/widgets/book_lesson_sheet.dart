import 'package:flutter/material.dart';

import '../data/class_model.dart';
import 'book_lesson_fields.dart';
import 'book_lesson_footer.dart';

/// Bottom sheet to book a lesson with [offering]: date, start time and
/// duration; the total price follows the teacher's hourly rate.
class BookLessonSheet extends StatefulWidget {
  const BookLessonSheet({super.key, required this.offering});

  final ClassOffering offering;

  @override
  State<BookLessonSheet> createState() => _BookLessonSheetState();
}

class _BookLessonSheetState extends State<BookLessonSheet> {
  DateTime? _date;
  TimeOfDay? _time;
  int _minutes = 60;

  DateTime? get _start => (_date == null || _time == null)
      ? null
      : DateTime(
          _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservar clase con ${widget.offering.displayName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          BookLessonFields(
            date: _date,
            time: _time,
            minutes: _minutes,
            onDate: (d) => setState(() => _date = d),
            onTime: (t) => setState(() => _time = t),
            onMinutes: (m) => setState(() => _minutes = m),
          ),
          const SizedBox(height: 12),
          BookLessonFooter(
            offering: widget.offering,
            start: _start,
            minutes: _minutes,
          ),
        ],
      ),
    );
  }
}
