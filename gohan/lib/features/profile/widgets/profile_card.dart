import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../data/player_profile.dart';
import 'avatar_picker.dart';
import 'edit_profile_sheet.dart';

/// Visual header of the own-profile screen: big avatar, name, key chips and
/// the entry point to edit the profile.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.favoriteSportName,
  });

  final PlayerProfile profile;
  final String? favoriteSportName;

  Widget _chip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 16, color: scheme.onSecondaryContainer),
      label: Text(label),
      backgroundColor: scheme.secondaryContainer,
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AvatarPicker(profile: profile),
            const SizedBox(height: 12),
            Text(
              profile.displayName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _chip(
                  context,
                  Icons.military_tech,
                  '${profile.rankingPoints} pts',
                ),
                _chip(
                  context,
                  Icons.signal_cellular_alt,
                  levelLabel(profile.level),
                ),
                if (favoriteSportName != null)
                  _chip(context, Icons.sports, favoriteSportName!),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => EditProfileSheet.show(context, profile),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
