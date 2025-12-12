
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _loading = false;
  String _role = "student";

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final res = await Api().postJson("/auth/login", body: {
        "identifier": _emailCtrl.text.trim(),  // IMPORTANT FIX
        "password": _passCtrl.text.trim(),
      });

      await Api().setToken(res["token"]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!"), backgroundColor: Colors.green),
      );

      //Navigator.pushReplacementNamed(context, "/home");
      Navigator.pushReplacementNamed(context, "/home");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Exam buddy",
          style: TextStyle(
            color: Color(0xFF2E3A8C),
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Help", style: TextStyle(color: Color(0xFF2E3A8C))),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text("Sign in", style: TextStyle(color: Color(0xFF2E3A8C))),
            ),
          ),
        ],
      ),

      // BODY
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
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

  // LEFT PART OF UI
  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in to access your clusters, notes and quizzes.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // Blue gradient info box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E3A8C), Color(0xFF6C5CE7)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 32),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Students can learn \n"
                      "Learn Sleep Repeat",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          "Why Exam buddy?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          "- Easy notes sharing and quiz management\n"
              "- Role-based access for teachers and students\n"
              "- Lightweight and runs locally",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  // RIGHT PART - SIGN IN FORM
  Widget _rightSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Sign in",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your credentials to continue.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // EMAIL
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter email";
              if (!value.contains("@")) return "Enter a valid email";
              return null;
            },
          ),
          const SizedBox(height: 16),

          // PASSWORD
          TextFormField(
            controller: _passCtrl,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: RadioListTile(
          //         value: "student",
          //         groupValue: _role,
          //         onChanged: (v) => setState(() => _role = v!),
          //         title: const Text("Student"),
          //       ),
          //     ),
          //     Expanded(
          //       child: RadioListTile(
          //         value: "admin",
          //         groupValue: _role,
          //         onChanged: (v) => setState(() => _role = v!),
          //         title: const Text("Teacher / Admin"),
          //       ),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 16),

          // LOGIN BUTTON
          ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB020),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text("Sign in"),
          ),

          const SizedBox(height: 16),

          // SIGNUP BUTTON
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
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
