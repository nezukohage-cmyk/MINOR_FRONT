// import 'package:flutter/material.dart';
// // void main() {
// //   runApp(const AskEmail());
// // }
// class AskEmail extends StatelessWidget {
//   const AskEmail({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.black38,
//         body: SafeArea(
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {},
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text("Hey, student please enter your Email", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:20,)
//                 ),
//                 Text("Create an account to start learning", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:8,)
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 ElevatedButton(onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       // backgroundColor: Colors.red,
//                       // foregroundColor: Colors.white,
//                     ),
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Text("Continue with phone number", style: TextStyle(fontSize: 15),),
//                     )
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                  Divider(
//                       thickness: 3,
//                       color: Colors.white,
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   decoration:
//                   InputDecoration(
//                       hintText: "Enter your Email",
//                       border: OutlineInputBorder()),
//                 ),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           "By continuing you agree to our user agreement and\nacknowledge that you understand the privacy policy.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontSize: 10),
//                         ),
//                       ),
//
//                       SizedBox(height: 10),
//
//                       SizedBox(
//                         width: 200,
//                         height: 69,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: Text("Continue", style: TextStyle(fontSize: 30)),
//                         ),
//                       ),
//
//                       SizedBox(height: 10), // spacing from screen bottom
//                     ],
//                   ),
//                 ),
//               ],
//             )
//         ),
//       ),
//     );
//   }
// }
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:Reddit/services/auth_service.dart';
import 'package:Reddit/homefeed.dart';
import 'package:Reddit/SignUp/sign.dart';

class logEmail extends StatefulWidget {
  const logEmail({super.key});

  @override
  State<logEmail> createState() => _logEmailState();
}

class _logEmailState extends State<logEmail> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false; // 👈 added password visibility toggle

  // --------------------
  // LOGIN FUNCTION
  // --------------------
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final pass = passController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await AuthService.login(email: email, password: pass);

      print("Login Success: $res");

      final prefs = await SharedPreferences.getInstance();

// Extract token from response
      final token = res["token"];
      if (token != null) {
        await prefs.setString("token", token);
        print("TOKEN SAVED = $token");
      } else {
        print("ERROR: backend returned no token");
      }

// Now navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeFeed()),
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
              "Hey, student please enter your Email",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const Text(
              "Login to continue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 15),

            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const Red()),
            //     );
            //   },
            //   child: const Text("Continue with phone number",
            //       style: TextStyle(fontSize: 15)),
            // ),

            const SizedBox(height: 20),
            const Divider(thickness: 3, color: Colors.white),
            const SizedBox(height: 20),



            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter your Email",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 20),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: passController,
                obscureText: !showPassword, // 👈 toggle here
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your Password",
                  border: const OutlineInputBorder(),
                  hintStyle: const TextStyle(color: Colors.white54),

                  // 👇 suffix icon added here
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword; // toggle state
                      });
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "By continuing you agree to our user agreement and\nacknowledge that you understand the privacy policy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),


        const SizedBox(height: 10),

                  // CONTINUE LOGIN BUTTON
                  SizedBox(
                    width: 200,
                    height: 69,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Continue", style: TextStyle(fontSize: 30)),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

