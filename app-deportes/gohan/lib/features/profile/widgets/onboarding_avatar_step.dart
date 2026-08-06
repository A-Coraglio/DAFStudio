import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/primary_submit_button.dart';
import '../providers/profile_providers.dart';
import 'avatar_picker.dart';

/// Final onboarding step — optional profile photo. The picker uploads on
/// tap; "Finalizar" submits the collected profile either way.
class OnboardingAvatarStep extends ConsumerWidget {
  const OnboardingAvatarStep({
    super.key,
    required this.onSubmit,
    required this.loading,
  });

  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Ponete una foto!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Los perfiles con foto generan más confianza al armar partidos. '
          'Es opcional — podés subirla después desde tu perfil.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (profile != null) Center(child: AvatarPicker(profile: profile)),
        const SizedBox(height: 28),
        PrimarySubmitButton(
          label: 'Empezar a jugar',
          onPressed: onSubmit,
          loading: loading,
        ),
      ],
    );
  }
}
