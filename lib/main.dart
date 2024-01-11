import 'package:flutter/material.dart';
import 'crypto_list_page.dart';
import 'shared_prefs_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _isDarkMode = await getThemeMode();
    setState(() {});
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    setThemeMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krypto Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        fontFamily: 'Arial',
      ),
      home: CryptoListPage(toggleTheme: _toggleTheme),
    );
  }
}
