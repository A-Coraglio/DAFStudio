import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
import '../data/player_profile.dart';
import 'avatar_picker.dart';
import 'edit_profile_sheet.dart';

/// Visual header of the own-profile screen — the player's "carnet": brand
/// gradient, avatar with an accent ring, name in the display face and chips.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.rankingPoints,
    required this.sportName,
  });

  final PlayerProfile profile;

  /// Ranking for the currently-selected sport (not an overall number).
  final int rankingPoints;

  /// Name of the sport the ranking belongs to (the active sport).
  final String? sportName;

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label, {
    bool accent = false,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final bg = accent ? colors.accent : Colors.white.withValues(alpha: .14);
    final fg = accent ? colors.onAccent : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    final gradient = brandGradient(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3),
            ),
            child: AvatarPicker(profile: profile),
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _chip(
                context,
                Icons.emoji_events,
                '$rankingPoints pts',
                accent: true,
              ),
              _chip(
                context,
                Icons.signal_cellular_alt,
                levelLabel(profile.level),
              ),
              if (sportName != null)
                _chip(context, Icons.sports, sportName!),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => EditProfileSheet.show(context, profile),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }
}
