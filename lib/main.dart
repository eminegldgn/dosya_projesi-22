import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const DersNotuApp(),
  );
}

class DersNotuApp extends StatelessWidget {
  const DersNotuApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notla',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}

