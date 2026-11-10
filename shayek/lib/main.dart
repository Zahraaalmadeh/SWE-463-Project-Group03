import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app_routes.dart';
import 'providers/checklist_provider.dart';
import 'providers/template_provider.dart';
import 'providers/trip_provider.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const ShayekApp());
}

/// Configures app-wide theme, named routes, and shared state.
class ShayekApp extends StatelessWidget {
  const ShayekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
      ],
      child: MaterialApp(
        title: 'Shayek',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185C45)),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1A2925),
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            insetPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          ),
        ),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
