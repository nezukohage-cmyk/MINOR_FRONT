// import 'package:flutter/material.dart';
// //
// // void main() {
// //   runApp(const PCold());
// // }
//
// class PCold extends StatefulWidget {
//   const PCold({super.key});
//
//   @override
//   State<PCold> createState() => _ColdState();
// }
//
// class _ColdState extends State<PCold> {
//   String countryCode = "+91";
//   TextEditingController phoneController = TextEditingController();
//
//   bool get isValid {
//     return phoneController.text.trim().length >= 10;
//   }
//
//   List<String> codes = ["+91", "+1", "+44", "+81", "+61"];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {},
//                       icon: const Icon(Icons.close, size: 28, color: Colors.white),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 const Center(
//                   child: Text(
//                     "Sign up or log in with your\nphone number",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           backgroundColor: Colors.black,
//                           builder: (_) {
//                             return ListView(
//                               padding: const EdgeInsets.all(20),
//                               children: codes.map((c) {
//                                 return ListTile(
//                                   title: Text(
//                                     c,
//                                     style: const TextStyle(fontSize: 18, color: Colors.white),
//                                   ),
//                                   onTap: () {
//                                     setState(() {
//                                       countryCode = c;
//                                     });
//                                     Navigator.pop(context);
//                                   },
//                                 );
//                               }).toList(),
//                             );
//                           },
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white),
//                           borderRadius: BorderRadius.circular(0),
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               countryCode,
//                               style: const TextStyle(fontSize: 16, color: Colors.white),
//                             ),
//                             const Icon(Icons.arrow_drop_down, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 10),
//
//                     Expanded(
//                       child: TextField(
//                         controller: phoneController,
//                         keyboardType: TextInputType.number,
//                         style: const TextStyle(color: Colors.white),
//                         onChanged: (v) {
//                           setState(() {});
//                         },
//                         decoration: InputDecoration(
//                           hintText: "Phone number",
//                           hintStyle: const TextStyle(color: Colors.white54),
//                           suffixIcon: phoneController.text.isNotEmpty
//                               ? GestureDetector(
//                             onTap: () {
//                               phoneController.clear();
//                               setState(() {});
//                             },
//                             child: const Icon(Icons.close, color: Colors.white),
//                           )
//                               : null,
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.red),
//                             borderRadius: BorderRadius.circular(0),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const Spacer(),
//
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4),
//                   child: Text(
//                     "Lexxi will use your phone number for account verification. "
//                         "By entering your phone number, you agree that Lexxi may send you "
//                         "verification messages via WhatsApp or SMS. SMS fees may apply.",
//                     style: TextStyle(fontSize: 12, color: Colors.white70),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//
//                 const SizedBox(height: 15),
//
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: isValid ? () {} : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50), // pill shape
//                       ),
//                     ),
//                     child: const Text(
//                       "Continue",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/VeriEmail.dart';
import 'package:Reddit/SignUp/sign.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/gender.dart';
class Pcold extends StatefulWidget {
  const Pcold({super.key});

  @override
  State<Pcold> createState() => _ColdState();
}

class _ColdState extends State<Pcold> {
  String countryCode = "+91";
  TextEditingController phoneController = TextEditingController();

  bool get isValid {
    return phoneController.text.trim().length >= 10;
  }

  List<String> codes = ["+91", "+1", "+44", "+81", "+61"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Sign up or log in with your\nphone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Red()));
                },
                child: const Align(
                  alignment: Alignment.center,
                  child: Text("Continue with phone number", style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (_) {
                          return ListView(
                            padding: const EdgeInsets.all(20),
                            children: codes.map((c) {
                              return ListTile(
                                title: Text(
                                  c,
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                onTap: () {
                                  setState(() {
                                    countryCode = c;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        children: [
                          Text(countryCode, style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: "Phone number",
                        hintStyle: const TextStyle(color: Colors.white54),
                        suffixIcon: phoneController.text.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            phoneController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.close, color: Colors.white),
                        )
                            : null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Lexxi will use your phone number for account verification. "
                      "By entering your phone number, you agree that Lexxi may send you "
                      "verification messages via WhatsApp or SMS. SMS fees may apply.",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>  G()));
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
