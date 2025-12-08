// import 'package:flutter/material.dart';
// // void main() {
// //   runApp(const G());
// // }
// class G extends StatelessWidget {
//   const G({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.black38,
//         body: SafeArea(
//             child: Column(
//               children: [
//                 Text("Select a gender", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:20,)
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 ElevatedButton(onPressed: () {},
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Text("Male", style: TextStyle(fontSize: 20),),
//                     )
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 ElevatedButton(onPressed: () {},
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Text("Female", style: TextStyle(fontSize: 20),),
//                     )
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 ElevatedButton(onPressed: () {},
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Prefer not to say", style: TextStyle(fontSize: 20),),
//                     )
//                 )
//               ],
//             )
//           // Buttons
//           // buildOptionButton("Man"),
//           // buildOptionButton("Woman"),
//           // buildOptionButton("Non-binary"),
//           // buildOptionButton("I prefer not to say"),
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/UserName.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/ColdStart.dart';
class G extends StatefulWidget {
  const G({super.key});

  @override
  State<G> createState() => _GState();
}

class _GState extends State<G> {
  String? selectedGender; // "male", "female", "none"

  Widget genderButton(String label, String value) {
    final bool isSelected = selectedGender == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedGender = value; // Only ONE selected at a time
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple.shade400 : Colors.black54,
        foregroundColor: Colors.white,
        minimumSize: const Size(200, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Select a gender",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 40),

            // Gender buttons
            genderButton("Male", "male"),
            const SizedBox(height: 15),

            genderButton("Female", "female"),
            const SizedBox(height: 15),

            genderButton("Prefer not to say", "none"),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: SizedBox(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedGender == null
                      ? null // disabled until selected
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Cold(),//this shit
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    selectedGender == null ? Colors.red.shade300 : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

