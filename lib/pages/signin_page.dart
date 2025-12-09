import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _role = "student";
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final res = await Api().postJson("/auth/login", body: {
        "email": _emailCtrl.text.trim(),
        "password": _passCtrl.text.trim(),
        "role": _role,
      });

      // Save JWT token
      await Api().setToken(res["token"]);

      // Navigate to home
      Navigator.pushReplacementNamed(context, "/home");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "Classroom Lite",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A8C),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Text("Log in",
                style: TextStyle(color: Color(0xFF2E3A8C))),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Help",
                style: TextStyle(color: Color(0xFF2E3A8C))),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E3A8C)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text("Sign in",
                  style: TextStyle(color: Color(0xFF2E3A8C))),
            ),
          )
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: isWide
                    ? Row(
                  children: [
                    Expanded(child: _leftSection()),
                    const SizedBox(width: 32),
                    Expanded(child: _rightSection()),
                  ],
                )
                    : Column(
                  children: [
                    _leftSection(),
                    const SizedBox(height: 20),
                    _rightSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in to access your classrooms, notes and quizzes.",
          style: TextStyle(fontSize: 15, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 22),

        // Blue/purple info ribbon
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E3A8C), Color(0xFF6C5CE7)],
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb,
                  color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Faculty/Admins can create classes and upload notes.\nStudents can join classes using a code.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        const Text("Why Classroom Lite?",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text(
          "- Easy notes sharing and quiz management\n"
              "- Role-based access for teachers and students\n"
              "- Lightweight and runs locally",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _rightSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Sign in",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            "Enter your credentials to continue.",
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Email
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (v) {
              if (v == null || v.isEmpty) return "Enter email";
              if (!v.contains("@")) return "Invalid email";
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
            validator: (v) {
              if (v == null || v.isEmpty) return "Enter password";
              if (v.length < 6) return "Must be at least 6 characters";
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Role selector
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  value: "student",
                  groupValue: _role,
                  onChanged: (v) {
                    setState(() => _role = v!);
                  },
                  title: const Text("Student"),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  value: "admin",
                  groupValue: _role,
                  onChanged: (v) {
                    setState(() => _role = v!);
                  },
                  title: const Text("Teacher / Admin"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Login button
          ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB020),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            )
                : const Text("Sign in"),
          ),

          const SizedBox(height: 12),

          // Google sign in (placeholder)
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.login, size: 18),
            label: const Text("Sign in with Google"),
          ),

          const SizedBox(height: 10),

          // Create account link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                child: const Text("Create one"),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Text(
            "This demo runs locally. Replace with your backend API.",
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
