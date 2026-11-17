import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk local database
  await Hive.initFlutter();

  // Membuka box Hive untuk users dan bookmarks
  await Hive.openBox('users');
  await Hive.openBox('bookmarks');

  // Cek sesi login tersimpan dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('loginData') ?? false;
  final String currentUser = prefs.getString('currentUser') ?? '';

  runApp(MainApp(
    isLoggedIn: isLoggedIn,
    currentUser: currentUser,
  ));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final String currentUser;

  const MainApp({
    super.key,
    required this.isLoggedIn,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: isLoggedIn
          ? HomeScreen(username: currentUser)
          : const LoginScreen(),
    );
  }
}
