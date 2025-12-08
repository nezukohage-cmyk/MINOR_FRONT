// import 'package:Reddit/SignUp/login.dart';
// import 'package:Reddit/SignUp/sign.dart';
// import 'package:flutter/material.dart';
// import '';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '2B',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: const AuthPager(),
//     );
//   }
// }
//
// class AuthPager extends StatefulWidget {
//   const AuthPager({super.key});
//
//   @override
//   State<AuthPager> createState() => _AuthPagerState();
// }
//
// class _AuthPagerState extends State<AuthPager> {
//   final PageController _controller = PageController(initialPage: 0);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: PageView(
//         controller: _controller,
//         children: [
//           Red(),   // Sign Up page
//           RL(),    // Log In page
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Reddit/SignUp/login.dart';
import 'package:Reddit/SignUp/sign.dart';
import 'services/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Api().init(
    baseUrl: "http://192.168.29.143:8080",
  );

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  if (token != null && token.isNotEmpty) {
    Api().setToken(token);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2B',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AuthPager(),
    );
  }
}

class AuthPager extends StatefulWidget {
  const AuthPager({super.key});

  @override
  State<AuthPager> createState() => _AuthPagerState();
}

class _AuthPagerState extends State<AuthPager> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _controller,
        children: const [
          Red(), // Sign Up page
          RL(),  // Login page
        ],
      ),
    );
  }
}
