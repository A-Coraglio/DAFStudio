import 'package:flutter/material.dart';

import '../../../core/widgets/illustrated_empty_state.dart';

/// Shown when the user has no chats yet.
class ChatListEmptyState extends StatelessWidget {
  const ChatListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const IllustratedEmptyState(
      icon: Icons.forum_outlined,
      title: 'Todavía no tenés chats',
      body: 'Cuando entres a un partido se crea su chat y lo vas a ver acá.',
    );
  }
}
