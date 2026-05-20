import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/onboarding_name_step.dart';
import '../widgets/onboarding_progress.dart';
import '../widgets/onboarding_sport_step.dart';

/// Shown right after register / login when the player profile is missing
/// first_name, last_name or favorite_sport_id. A two-step flow — name, then
/// favorite sport. The router guard blocks /home until it's done.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  int? _sportId;
  int _step = 0;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_nameFormKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  Future<void> _submit() async {
    if (_sportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí tu deporte favorito.')),
      );
      return;
    }
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
      appBar: AppBar(
        title: const Text('Completá tu perfil'),
        automaticallyImplyLeading: false,
        leading: _step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step = 0),
              ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                OnboardingProgress(step: _step, total: 2),
                const SizedBox(height: 24),
                if (_step == 0)
                  OnboardingNameStep(
                    formKey: _nameFormKey,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    onContinue: _next,
                  )
                else
                  OnboardingSportStep(
                    sportId: _sportId,
                    onChanged: (v) => setState(() => _sportId = v),
                    onSubmit: _submit,
                    loading: _loading,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
