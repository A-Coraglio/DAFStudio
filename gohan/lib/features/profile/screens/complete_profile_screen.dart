import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/onboarding_avatar_step.dart';
import '../widgets/onboarding_level_step.dart';
import '../widgets/onboarding_name_step.dart';
import '../widgets/onboarding_progress.dart';
import '../widgets/onboarding_sport_step.dart';

/// Shown right after register / login when the player profile is missing
/// first_name, last_name or favorite_sport_id. Four steps — name, favorite
/// sport, optional level, optional photo. The router guard blocks /home
/// until it's done.
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
  String? _level;
  int _step = 0;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _nextFromName() {
    if (_nameFormKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  void _nextFromSport() {
    if (_sportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí tu deporte favorito.')),
      );
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).updateMyProfile(
            UpdatePlayerRequest(
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              favoriteSportId: _sportId,
              level: _level,
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
                onPressed: () => setState(() => _step -= 1),
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
                OnboardingProgress(step: _step, total: 4),
                const SizedBox(height: 24),
                switch (_step) {
                  0 => OnboardingNameStep(
                      formKey: _nameFormKey,
                      firstNameCtrl: _firstNameCtrl,
                      lastNameCtrl: _lastNameCtrl,
                      onContinue: _nextFromName,
                    ),
                  1 => OnboardingSportStep(
                      sportId: _sportId,
                      onChanged: (v) => setState(() => _sportId = v),
                      onSubmit: _nextFromSport,
                      loading: false,
                    ),
                  2 => OnboardingLevelStep(
                      level: _level,
                      onChanged: (v) => setState(() => _level = v),
                      onContinue: () => setState(() => _step = 3),
                    ),
                  _ => OnboardingAvatarStep(
                      onSubmit: _submit,
                      loading: _loading,
                    ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
