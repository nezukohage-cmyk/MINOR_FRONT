// import 'package:flutter/material.dart';
// // void main() {
// //   runApp(const Verify());
// // }
// class Verify extends StatelessWidget {
//   const Verify({super.key});
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
//                 Text("Verify your Email", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:20,)
//                 ),
//                 SizedBox(
//                   height: 7,
//                 ),
//                 Text("Enter the 6 digit code we have sent to email", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:8,)
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   decoration:
//                   InputDecoration(
//                       hintText: "Verification code",
//                       border: OutlineInputBorder()),
//                 ),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           "Didnt get a code? Resend in |timer|",
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

import 'package:flutter/material.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/gender.dart';

class Verify extends StatelessWidget {
  const Verify({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

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
            const Text("Verify your Email", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            const SizedBox(height: 7),
            const Text("Enter the 6 digit code we have sent to email", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 8)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: codeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Verification code", border: OutlineInputBorder(), hintStyle: TextStyle(color: Colors.white54)),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Didn't get a code? Resend in |timer|",
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const G()));
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
    );
  }
}
