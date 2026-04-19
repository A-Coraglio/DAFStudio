import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import '../../sports/widgets/sport_dropdown_field.dart';
import '../widgets/name_field.dart';

/// Shown right after register / login when the player profile is missing
/// first_name, last_name or favorite_sport_id. User can't reach /home until
/// they fill it in — the router guard enforces that.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  int? _sportId;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).updateMyProfile(
            UpdatePlayerRequest(
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              favoriteSportId: _sportId,
            ),
          );
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completá tu perfil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Contanos un poco sobre vos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Usamos esto para armar partidos y mostrar tu perfil.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  NameField(
                    controller: _firstNameCtrl,
                    label: 'Nombre',
                  ),
                  const SizedBox(height: 12),
                  NameField(
                    controller: _lastNameCtrl,
                    label: 'Apellido',
                  ),
                  const SizedBox(height: 12),
                  SportDropdownField(
                    value: _sportId,
                    onChanged: (v) => setState(() => _sportId = v),
                  ),
                  const SizedBox(height: 24),
                  PrimarySubmitButton(
                    label: 'Guardar',
                    onPressed: _submit,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
