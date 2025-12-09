import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _role = "student";
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final res = await Api().postJson("/auth/signup", body: {
        "username": _nameCtrl.text.trim(),     // IMPORTANT FIX
        "email": _emailCtrl.text.trim(),
        "phone": "",                           // backend allows this
        "password": _passCtrl.text.trim(),
      });

      await Api().setToken(res["token"]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!"), backgroundColor: Colors.green),
      );

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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Create account",
          style: TextStyle(
            color: Color(0xFF2E3A8C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Create your account to start using Classroom Lite.",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),

                      const SizedBox(height: 20),

                      // FULL NAME
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: "Full Name"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter your full name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // EMAIL
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter email";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

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


                      const SizedBox(height: 18),

                      // ROLE SELECTION
                      const Text(
                        "Select role",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              value: "student",
                              groupValue: _role,
                              onChanged: (v) => setState(() => _role = v!),
                              title: const Text("Student"),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              value: "admin",
                              groupValue: _role,
                              onChanged: (v) => setState(() => _role = v!),
                              title: const Text("Teacher / Admin"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // CREATE ACCOUNT BUTTON
                      ElevatedButton(
                        onPressed: _loading ? null : _createAccount,
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
                            : const Text("Create account"),
                      ),

                      const SizedBox(height: 14),

                      // BACK TO LOGIN
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                        child: const Text("Back to sign in"),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        "This runs locally. Replace with your backend endpoint.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
