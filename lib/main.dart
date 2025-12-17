import 'package:Reddit/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AUTH SCREENS
import 'package:Reddit/SignUp/login.dart';   // LoginPage
import 'package:Reddit/SignUp/sign.dart';    // SignUpPage

// API
import 'services/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API with your backend address
  await Api().init(
    baseUrl: "http://192.168.14.62:8080",//home
   // baseUrl: "http://192.168.14.82:8080",
  );

  // Restore saved JWT token if exists
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  if (token != null && token.isNotEmpty) {
    Api().setToken(token);
  }


  runApp(const ExamBuddyApp());
}

class ExamBuddyApp extends StatelessWidget {
  const ExamBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Exam Buddy",
      debugShowCheckedModeBanner: false,

      // App starts at login page
      initialRoute: "/",

      routes: {
        "/": (context) => const LoginPage(),      // Beautiful sign-in UI
        "/login": (context) => const LoginPage(), // Same page
        "/signup": (context) => const SignUpPage(),
        "/home": (context) => const HomePage(),

      },
    );
  }
}