import 'package:flutter/material.dart';
import 'auth_storage.dart';
import 'login_page.dart';
import 'main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasToken() async {
    final token = await AuthStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        // Mientras lee storage
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snapshot.data == true;

        if (loggedIn) {
          return const MyHomePage(title: 'Home');
        } else {
          return LoginPage();
        }
      },
    );
  }
}
