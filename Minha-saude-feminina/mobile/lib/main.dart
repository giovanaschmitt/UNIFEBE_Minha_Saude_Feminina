import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/cycle_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Saúde Feminina - UNIFEBE',
      scaffoldMessengerKey: NotificationService.instance.mensageiro,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user != null) {
            return _AreaLogada(key: ValueKey(user.uid), uid: user.uid);
          }
          return const SignInScreen();
        },
      ),
    );
  }
}

/// Prepara os dados da usuária logada (ciclos da conta e notificações)
/// antes de mostrar a Home.
class _AreaLogada extends StatefulWidget {
  final String uid;

  const _AreaLogada({super.key, required this.uid});

  @override
  State<_AreaLogada> createState() => _AreaLogadaState();
}

class _AreaLogadaState extends State<_AreaLogada> {
  late final Future<void> _preparo;

  @override
  void initState() {
    super.initState();
    _preparo = CycleService.instance.entrar(widget.uid);
    NotificationService.instance.entrar();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _preparo,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const HomeScreen();
      },
    );
  }
}
