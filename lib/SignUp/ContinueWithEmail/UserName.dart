// import 'package:flutter/material.dart';
// // void main() {
// //   runApp(const UniqueUserName());
// // }
// class UniqueUserName extends StatelessWidget {
//   const UniqueUserName({super.key});
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
//                     child: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {},
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text("Create yoour username", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:20,)
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text("Pick a name to use on lexxi. Choose carefully, you wont be able to change it later.", textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:15,)
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   decoration:
//                   InputDecoration(
//                       hintText: "Enter your usesrname",
//                       border: OutlineInputBorder()),
//                 ),
//                 // SizedBox(
//                 //   height: 599,
//                 // ),
//                 Expanded(// adi expanded ga use maadud kali hudga
//                   child:Align(
//                     alignment: Alignment.bottomCenter,
//                     child:SizedBox(
//                       width: 200,
//                       height: 69,
//                       child:ElevatedButton(onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Text("Continue", style: TextStyle(fontSize: 30),),
//                           )
//                       ) ,
//
//                     )
//                   )
//                 ),
//               ],
//             )
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/ColdStart.dart';

class UniqueUserName extends StatelessWidget {
  const UniqueUserName({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
            const SizedBox(height: 10),
            const Text("Create your username", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            const SizedBox(height: 15),
            const Text("Pick a name to use on lexxi. Choose carefully, you wont be able to change it later.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Enter your username", border: OutlineInputBorder(), hintStyle: TextStyle(color: Colors.white54)),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 200,
                  height: 69,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Cold()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Align(alignment: Alignment.center, child: Text("Continue", style: TextStyle(fontSize: 30))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
