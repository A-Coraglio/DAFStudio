import 'package:flutter/material.dart';

import '../../../core/widgets/primary_submit_button.dart';
import 'name_field.dart';

/// Step 1 of onboarding — first + last name. Owns its own [Form] so the
/// "Siguiente" button validates only these two fields.
class OnboardingNameStep extends StatelessWidget {
  const OnboardingNameStep({
    super.key,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te llamás?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Así te van a reconocer los demás jugadores.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          NameField(controller: firstNameCtrl, label: 'Nombre'),
          const SizedBox(height: 12),
          NameField(controller: lastNameCtrl, label: 'Apellido'),
          const SizedBox(height: 24),
          PrimarySubmitButton(
            label: 'Siguiente',
            onPressed: onContinue,
            loading: false,
          ),
        ],
      ),
    );
  }
}
