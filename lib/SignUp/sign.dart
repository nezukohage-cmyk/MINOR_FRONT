// import 'package:flutter/material.dart';
// class Red extends StatelessWidget {
//   const Red({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//         Scaffold(
//             backgroundColor: Colors.black38,
//             body: SafeArea(
//                 child:
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 200
//                         ,
//                       ),
//                       Text("Sign up for lexi", textAlign: TextAlign.center,
//                           style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:20,)
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       SizedBox(
//                           height: 50,
//                           width: 500,
//                           child: ElevatedButton(onPressed: (){
//
//                           },
//                               child:Align(
//                                 alignment: Alignment.center,
//                                 child: Text("continue with email", style: TextStyle(fontSize: 20),),
//                               ))
//                       ),
//                       SizedBox(
//                         height: 6.9,
//                       ),
//                       SizedBox(
//                           height: 50,
//                           width: 500,
//                           child: ElevatedButton(onPressed: (){},
//                               child:Align(
//                                 alignment: Alignment.center,
//                                 child: Text("continue with google", style: TextStyle(fontSize: 20),),
//                               ))
//                       ),
//                       SizedBox(
//                         height: 6.9,
//                       ),
//                       SizedBox(
//                           height: 50,
//                           width: 500,
//                           child: ElevatedButton(onPressed: (){},
//                               child:Align(
//                                 alignment: Alignment.center,
//                                 child: Text("continue with number", style: TextStyle(fontSize: 20),),
//                               ))
//                       ),
//
//                       SizedBox(
//                         height: 6.9,
//                       ),
//                       SizedBox(
//                         height: 269,
//                       ),
//                       Text("by continuing you agree to our user aggrement and acknowledge that you understand the privacy policy.", textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white,fontSize:10,)
//                       ),
//                       SizedBox(
//                         height: 20,
//                         width: 600,
//                         child: Divider(
//                           height: 6,
//                           thickness: 2,
//                         ),
//                       ),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Already have an account?", textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.white,fontSize:14,)
//                           ),
//                           SizedBox(width: 5,),
//                           ElevatedButton(onPressed: (){}, child: Text("Log in"))
//                         ],
//                       )
//                     ],
//                   ),
//                 )
//             )
//
//
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/EmailAsking.dart';
import 'package:Reddit/SignUp/ContinueWithEmail/PhoneStart.dart';
import 'Login.dart';

class Red extends StatelessWidget {
  const Red({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              const Text("Sign up for lexi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 500,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AskEmail()));
                  },
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text("continue with email", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(height: 6.9),
              SizedBox(
                height: 50,
                width: 500,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Google sign-in coming soon")));
                  },
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text("continue with google", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(height: 6.9),
              SizedBox(
                height: 50,
                width: 500,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Pcold()));
                  },
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text("continue with number", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "by continuing you agree to our user aggrement and acknowledge that you understand the privacy policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                width: 600,
                child: const Divider(
                  height: 6,
                  thickness: 2,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RL()));
                    },
                    child: const Text("Log in"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
