import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora datos fake. Más adelante los traés de la API (/me)
    const email = 'agustin@ciberideas.es';
    const nombre = 'Agustín';

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
              children: const [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(nombre),
                  subtitle: Text(email),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Estado'),
                  subtitle: Text('Cuenta activa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
