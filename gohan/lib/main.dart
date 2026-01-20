import 'package:flutter/material.dart';
import 'login_page.dart';
import 'auth_gate.dart';
import 'auth_storage.dart';
import 'preferences.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const MyHomePage(title: 'Home'),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override 
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  String? _sport;

  final _sports = const [
    'Fútbol',
    'Básquet',
    'Tenis',
    'Natación',
    'Ciclismo',
  ] ;
  @override
  void initState() {
    super.initState();
    _loadSport();
  }
  
  Future<void> _loadSport() async {
    final saved = await Preferences.getSport();
    if (!mounted) return;
    setState(() => _sport = saved);
  }
  
  Future<void> _pickSport() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _sports
              .map((s) => ListTile(
                    title: Text(s),
                    trailing: _sport == s ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(ctx, s),
                  ))
              .toList(),
        ),
      ),
    );

    if (chosen == null) return;

    await Preferences.setSport(chosen);
    if (!mounted) return;
    setState(() => _sport = chosen);
  }

  Future<void> _logout() async {
  await AuthStorage.clearToken();
  if (!mounted) return;
  Navigator.of(context).pushReplacementNamed('/login');
}

  @override
  Widget build(BuildContext context) {
    final sportLabel = _sport ?? 'Elegir deporte';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton.icon(
            onPressed: _pickSport,
            icon: const Icon(Icons.sports),
            label: Text(sportLabel),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ), 
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Bienvenido 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            
            if (_sport == null) ...[
              Text(
                'Antes de continuar, elegí el deporte para continuar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                'Deporte actual: $_sport',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Elegí una opción para continuar.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Tarjeta: Configuración
            _HomeCard(
              icon: Icons.settings,
              title: 'Configuración',
              subtitle: 'Preferencias de la app',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todavía no hicimos Configuración')),
                );
              },
            ),

            // Tarjeta: Otra sección (puede ser partidos)
            _HomeCard(
              icon: Icons.list_alt,
              title: 'Listado',
              subtitle: 'Ejemplo de sección con datos',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todavía no hicimos Listado')),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
      heroTag: 'profileFab',
      tooltip: 'Perfil',
      onPressed: () => Navigator.of(context).pushNamed('/profile'),
      child: const Icon(Icons.person),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
    }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  } 
}