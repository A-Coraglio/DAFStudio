import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../lessons/providers/lessons_providers.dart';
import '../data/class_model.dart';

/// Price summary + submit of the booking sheet. Owns the booking mutation:
/// on success it closes the sheet and refreshes "mis clases".
class BookLessonFooter extends ConsumerStatefulWidget {
  const BookLessonFooter({
    super.key,
    required this.offering,
    required this.start,
    required this.minutes,
    required this.sportId,
  });

  final ClassOffering offering;

  /// Null while the form is incomplete (no date/time picked yet).
  final DateTime? start;
  final int minutes;

  /// Sport of the lesson; null when the teacher has several and none was
  /// picked yet (the backend also auto-fills single-sport teachers).
  final int? sportId;

  @override
  ConsumerState<BookLessonFooter> createState() => _BookLessonFooterState();
}

class _BookLessonFooterState extends ConsumerState<BookLessonFooter> {
  bool _busy = false;

  Future<void> _submit() async {
    final start = widget.start!;
    setState(() => _busy = true);
    try {
      await ref.read(lessonsRepositoryProvider).book(
            teacherId: widget.offering.id,
            start: start,
            end: start.add(Duration(minutes: widget.minutes)),
            sportId: widget.sportId,
          );
      ref.invalidate(myLessonsProvider);
      ref.invalidate(teacherBusySlotsProvider(widget.offering.id));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Clase reservada!')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.offering.pricePerHour * widget.minutes / 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total: \$${price.round()}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        PrimarySubmitButton(
          label: 'Reservar',
          loading: _busy,
          onPressed: widget.start == null ? null : _submit,
        ),
      ],
    );
  }
}
