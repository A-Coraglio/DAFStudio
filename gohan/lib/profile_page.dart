import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Sin email';
    final nombre = (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        email.split('@').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(nombre),
                  subtitle: Text(email),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Estado'),
                  subtitle: Text(user == null ? 'Sin sesión' : 'Cuenta activa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
