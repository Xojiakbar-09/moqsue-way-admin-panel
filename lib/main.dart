import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'src/core/consts/app_themes.dart';
import 'src/features/auth/bloc/auth_bloc.dart';
import 'src/features/auth/presentation/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(FirebaseAuth.instance),
      child: MaterialApp(
        title: 'Masjid Admin',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.create(Brightness.light),
        darkTheme: AppThemes.create(Brightness.dark),
        home: const AuthPage(),
      ),
    );
  }
}
