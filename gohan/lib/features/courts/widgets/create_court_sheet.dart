import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/primary_submit_button.dart';
import 'court_form_fields.dart';
import 'create_court_action.dart';

/// Alta de cancha dentro de un club propio.
class CreateCourtSheet extends ConsumerStatefulWidget {
  const CreateCourtSheet({super.key, required this.clubId});

  final int clubId;

  static Future<void> show(BuildContext context, int clubId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateCourtSheet(clubId: clubId),
    );
  }

  @override
  ConsumerState<CreateCourtSheet> createState() => _CreateCourtSheetState();
}

class _CreateCourtSheetState extends ConsumerState<CreateCourtSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  int? _sportId;
  bool _indoor = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await submitCreateCourt(
      context,
      ref,
      clubId: widget.clubId,
      name: _name.text,
      sportId: _sportId,
      priceText: _price.text,
      indoor: _indoor,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nueva cancha', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CourtFormFields(
              nameCtrl: _name,
              priceCtrl: _price,
              sportId: _sportId,
              onSport: (id) => setState(() => _sportId = id),
              indoor: _indoor,
              onIndoor: (v) => setState(() => _indoor = v),
            ),
            PrimarySubmitButton(
              label: 'Crear cancha',
              loading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
