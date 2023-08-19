import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:notifica/pages/create_account/create_account.dart';
import 'package:notifica/pages/home/home.dart';
import 'package:notifica/pages/home/pages/about/about.dart';
import 'package:notifica/pages/home/pages/create_occurrence/create_occurrence.dart';
import 'package:notifica/pages/home/pages/occurrences/occurrences.dart';
import 'package:notifica/pages/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Notifica());
}

class Notifica extends StatefulWidget {
  const Notifica({super.key});

  @override
  State<Notifica> createState() => _NotificaState();
}

class _NotificaState extends State<Notifica> {
  final fireAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fireAuth.authStateChanges().listen((user) {
      if (user == null && mounted) {
        try {
          context.go('/');
        } catch (_) {}
      }
    });
  }

  late final _router = GoRouter(
    initialLocation: '/home/occurrences',
    redirect: (BuildContext context, GoRouterState state) {
      final currentUser = fireAuth.currentUser;
      final path = state.fullPath ?? '';

      if (currentUser == null && path.contains('/home')) {
        return '/';
      } else {
        return null;
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/createAccount',
        builder: (context, state) => const CreateAccount(),
      ),
      ShellRoute(
        builder: (_, state, child) => Homepage(state: state, child: child),
        routes: [
          GoRoute(
            path: '/home/occurrences',
            builder: (context, state) => const OccurrencesPage(),
          ),
          GoRoute(
            path: '/home/createOccurrence',
            builder: (context, state) => const CreateOccurrencePage(),
          ),
          GoRoute(
            path: '/home/about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MaterialApp.router(
        title: 'Notifica',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff4ECDB6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff4ECDB6),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}
