import 'package:Reddit/HomeFeed.dart';
import 'package:flutter/material.dart';
//import 'package:Reddit/homefeed.dart.dart';
import 'package:Reddit/SignUp/sign.dart';
// void main() {
//   runApp(const pas());
// }

class pas extends StatelessWidget {
  const pas({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return MaterialApp(
        home:Scaffold(
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
                const Text("Enter your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                const SizedBox(height: 25),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (_) => const Red()));
                //   },
                //   child: const Align(
                //     alignment: Alignment.center,
                //     child: Text("Continue with phone number", style: TextStyle(fontSize: 15)),
                //   ),
                // ),
                const SizedBox(height: 20),
                //const Divider(thickness: 3, color: Colors.white),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Enter your Password", border: OutlineInputBorder(), hintStyle: TextStyle(color: Colors.white54)),
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
                      SizedBox(
                        width: 200,
                        height: 69,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeFeed()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: const Text("Continue", style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
