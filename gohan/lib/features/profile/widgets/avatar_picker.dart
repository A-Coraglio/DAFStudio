import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/http/api_client.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import 'profile_avatar.dart';

/// Tappable avatar that opens the OS image picker and uploads the chosen
/// image to /api/players/me/avatar/. Invalidates the profile provider on
/// success so every screen watching it refreshes the picture.
class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  bool _uploading = false;

  String get _initials {
    final a = widget.profile.firstName?.trim().isNotEmpty == true
        ? widget.profile.firstName!.trim()[0]
        : '';
    final b = widget.profile.lastName?.trim().isNotEmpty == true
        ? widget.profile.lastName!.trim()[0]
        : '';
    final s = (a + b).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(bytes: bytes, filename: picked.name);
      ref.invalidate(myProfileProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _uploading ? null : _pickAndUpload,
          child: ProfileAvatar(
            avatarUrl: widget.profile.avatarUrl,
            initials: _initials,
            radius: 48,
          ),
        ),
        if (_uploading)
          const Positioned.fill(
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.camera_alt,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
      ],
    );
  }
}
