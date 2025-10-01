import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../firebase_options.dart';
import 'router/admin_router.dart';
import 'providers/admin_auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData baseLight = AppTheme.lightTheme;
    final ThemeData baseDark = AppTheme.darkTheme;

    return ChangeNotifierProvider(
      create: (_) => AdminAuthProvider(),
      child: MaterialApp.router(
        title: 'Moi Église TV Admin',
        theme: baseLight.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseLight.textTheme),
        ),
        darkTheme: baseDark.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseDark.textTheme),
        ),
        routerConfig: AdminRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

