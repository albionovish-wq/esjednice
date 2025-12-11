import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/sucelja/prijava.dart';
import 'package:esjednice/sucelja/dashboard.dart';
import 'package:esjednice/sucelja/sjednice.dart';
import 'package:esjednice/sucelja/detalji_sjednice.dart';
import 'package:esjednice/sucelja/grupe.dart';
import 'package:esjednice/sucelja/glasanja.dart';
import 'package:esjednice/sucelja/komunikacija.dart';
import 'package:esjednice/sucelja/postavke.dart';
import 'package:esjednice/provideri/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'eSjednice',
      theme: AppDesign.theme,
      home: authState.when(
        data: (user) {
          return user != null ? const DashboardEkran() : const PrijavaEkran();
        },
        error: (error, stack) => const PrijavaEkran(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/prijava':
            return MaterialPageRoute(builder: (_) => const PrijavaEkran());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardEkran());
          case '/meetings':
            return MaterialPageRoute(builder: (_) => const SjedniceEkran());
          case '/sjednica':
            final sjednicaId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => DetaljiSjedniceEkran(sjednicaId: sjednicaId),
            );
          case '/groups':
            return MaterialPageRoute(builder: (_) => const GrupeEkran());
          case '/voting':
            return MaterialPageRoute(builder: (_) => const GlasanjaEkran());
          case '/communication':
            return MaterialPageRoute(builder: (_) => const KomunikacijaEkran());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const PostavkeEkran());
          default:
            return MaterialPageRoute(builder: (_) => const DashboardEkran());
        }
      },
    );
  }
}
