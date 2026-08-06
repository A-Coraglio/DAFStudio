import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/primary_submit_button.dart';
import '../data/admin_user.dart';
import '../widgets/club_form_fields.dart';
import '../widgets/create_club_action.dart';
import '../widgets/owner_picker.dart';

/// Alta de club (solo admin): se elige el dueño y los datos del club.
class AdminCreateClubScreen extends ConsumerStatefulWidget {
  const AdminCreateClubScreen({super.key});

  @override
  ConsumerState<AdminCreateClubScreen> createState() =>
      _AdminCreateClubScreenState();
}

class _AdminCreateClubScreenState
    extends ConsumerState<AdminCreateClubScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  AdminUser? _owner;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await submitCreateClub(
      context,
      ref,
      owner: _owner,
      name: _name.text,
      address: _address.text,
      city: _city.text,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear club')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OwnerPicker(
            selected: _owner,
            onPick: (u) => setState(() => _owner = u),
            onClear: () => setState(() => _owner = null),
          ),
          const SizedBox(height: 12),
          ClubFormFields(
            nameCtrl: _name,
            addressCtrl: _address,
            cityCtrl: _city,
          ),
          const SizedBox(height: 20),
          PrimarySubmitButton(
            label: 'Crear club',
            loading: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
