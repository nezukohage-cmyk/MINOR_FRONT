import 'package:flutter/material.dart';
import 'package:Reddit/quiz.dart';
class DummyHome extends StatefulWidget {
  const DummyHome({super.key});

  @override
  State<DummyHome> createState() => _DummyHomeState();
}

class _DummyHomeState extends State<DummyHome> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    HomePageUI(),
    QuizPage(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Answers"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "You"),
        ],
      ),
    );
  }
}


/// ------------------------------------------------------
/// HOME PAGE UI WIDGET
/// ------------------------------------------------------
class HomePageUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Icon(Icons.menu),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white54),
              SizedBox(width: 8),
              Text("Find anything", style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Text("OS"),
                SizedBox(width: 20),
                Text("Cloud"),
              ],
            ),

            SizedBox(height: 25),

            Text("Suggested for you", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("r/SDMCET • 1d", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text("Dummy headline text", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text("dummy image", style: TextStyle(color: Colors.white54)),
                    ),
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.white54),
                          SizedBox(width: 4),
                          Text("69"),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_downward, color: Colors.white54),
                          SizedBox(width: 12),
                          Icon(Icons.chat_bubble_outline, color: Colors.white54),
                          SizedBox(width: 4),
                          Text("69"),
                        ],
                      ),
                      Icon(Icons.share_outlined, color: Colors.white54),
                    ],
                  ),

                  SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
