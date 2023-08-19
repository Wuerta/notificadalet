import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final fireAuth = FirebaseAuth.instance;
  late final currentUser = fireAuth.currentUser;

  int get selectedIndex {
    final path = widget.state.fullPath;

    if (path == '/home/occurrences') return 0;
    if (path == '/home/createOccurrence') return 1;
    if (path == '/home/about') return 2;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${currentUser?.displayName ?? 'Sem Nome'}!'),
        actions: [
          IconButton(
            onPressed: () async {
              context.go('/');
              await fireAuth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == selectedIndex) return;
          if (index == 0) context.go('/home/occurrences');
          if (index == 1) context.go('/home/createOccurrence');
          if (index == 2) context.go('/home/about');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.warning),
            label: 'Ocorrências',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_alert),
            label: 'Adicionar',
          ),
          NavigationDestination(
            icon: Icon(Icons.help),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}
