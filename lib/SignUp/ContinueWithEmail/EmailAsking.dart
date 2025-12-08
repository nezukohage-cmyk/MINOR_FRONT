import 'package:flutter/material.dart';
import 'package:Reddit/services/auth_service.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/gender.dart';
import 'package:Reddit/SignUp/sign.dart';

class AskEmail extends StatefulWidget {
  const AskEmail({super.key});

  @override
  State<AskEmail> createState() => _AskEmailState();
}

class _AskEmailState extends State<AskEmail> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  Future<void> signupUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    // VALIDATION
    if (username.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Email signup → phone empty
      await AuthService.signup(
        name: username,
        email: email,
        phone: "",
        password: pass,
      );

      // SUCCESS → Go to gender or home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const G()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hey, student enter your signup details",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            ),
            const Text(
              "Create an account to start learning",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
            ),
            const SizedBox(height: 20),

            // -------------------
            // FORM
            // -------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  // USERNAME FIELD
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter Username",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // PASSWORD FIELD
                  TextField(
                    controller: passController,
                    obscureText: !showPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() => showPassword = !showPassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // CONFIRM PASSWORD FIELD
                  TextField(
                    controller: confirmPassController,
                    obscureText: !showConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() => showConfirmPassword = !showConfirmPassword);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // FOOTER + SIGNUP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    "By continuing you agree to our user agreement and acknowledge that you understand the privacy policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: 200,
                    height: 69,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Continue", style: TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
