import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final int semester;

  const QuizPage({super.key, required this.semester});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? selectedSubject;
  String? selectedTopic;

  final TextEditingController questionCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();

  // TEMP dummy data (replace with backend)
  List<String> subjects = ["OS", "DSA", "DBMS", "CN"];
  List<String> topics = ["Basics", "Advanced", "MCQs", "Revision"];

  @override
  Widget build(BuildContext context) {
    const themeBlue = Color(0xFF2E3A8C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: themeBlue,
        title: Text(
          "Quiz Setup (Sem ${widget.semester})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // MAIN CARD CONTAINER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Configure Your Quiz",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeBlue,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SUBJECT DROPDOWN
                  _label("Subject"),
                  const SizedBox(height: 8),

                  _dropdown(
                    value: selectedSubject,
                    hint: "Select Subject",
                    items: subjects,
                    onChanged: (v) => setState(() => selectedSubject = v),
                  ),

                  const SizedBox(height: 22),

                  // TOPIC DROPDOWN
                  _label("Topic"),
                  const SizedBox(height: 8),

                  _dropdown(
                    value: selectedTopic,
                    hint: "Select Topic",
                    items: topics,
                    onChanged: (v) => setState(() => selectedTopic = v),
                  ),

                  const SizedBox(height: 22),

                  // NUMBER OF QUESTIONS INPUT
                  _label("No. of Questions"),
                  const SizedBox(height: 8),

                  _inputField(
                    controller: questionCtrl,
                    hint: "Enter number",
                    keyboard: TextInputType.number,
                  ),

                  const SizedBox(height: 22),

                  // TIME INPUT
                  _label("Time (minutes)"),
                  const SizedBox(height: 8),

                  _inputField(
                    controller: timeCtrl,
                    hint: "Enter duration",
                    keyboard: TextInputType.number,
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // START BUTTON
            Center(
              child: SizedBox(
                width: 260,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _validateAndStart,
                  child: const Text(
                    "Start Quiz",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------ UI COMPONENTS ------------------

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E3A8C),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboard,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ------------------ VALIDATION LOGIC ------------------

  void _validateAndStart() {
    if (selectedSubject == null ||
        selectedTopic == null ||
        questionCtrl.text.trim().isEmpty ||
        timeCtrl.text.trim().isEmpty) {
      _toast("Please fill all fields");
      return;
    }

    _toast("Quiz starting...");

    // TODO: Call backend API to start quiz
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
