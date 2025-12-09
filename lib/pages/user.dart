// lib/pages/user.dart
import 'package:flutter/material.dart';
import 'package:Reddit/pages/chat/chat_home.dart';
// import your analysis & todo pages if exist
// import 'package:Reddit/pages/analysis.dart';
// import 'package:Reddit/pages/todo_list.dart';
import 'package:Reddit/pages/chat/chat_home.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[300],
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("You"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ElevatedButton(
              style: btnStyle,
              onPressed: () {
                // TODO: wire Analysis page here
                // Navigator.push(context, MaterialPageRoute(builder: (_) => AnalysisPage()));
              },
              child: const Text("Analysis", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: btnStyle,
              onPressed: () {
                // Open the Chat Home (sessions + chat window)
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHomePage()));
              },
              child: const Text("Chatbot", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: btnStyle,
              onPressed: () {
                // TODO: wire Todo list page here
                // Navigator.push(context, MaterialPageRoute(builder: (_) => TodoListPage()));
              },
              child: const Text("Todo list", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
