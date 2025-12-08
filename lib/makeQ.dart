import 'package:flutter/material.dart';
import 'package:Reddit/quiz.dart';
class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  // Dummy subject → topics mapping
  final Map<String, List<String>> topicsBySubject = {
    "Operating Systems": ["Processes", "Threads", "Deadlocks", "Scheduling"],
    "DBMS": ["SQL", "ER Model", "Joins", "Transactions"],
    "Data Structures": ["Arrays", "Trees", "Graphs", "Stacks"],
  };

  // user selections
  String selectedSubject = "";
  List<String> selectedTopics = [];
  String? correctAnswer;

  // text controllers
  final qController = TextEditingController();
  final aController = TextEditingController();
  final bController = TextEditingController();
  final cController = TextEditingController();
  final dController = TextEditingController();

  bool get isAllFilled {
    return selectedSubject.isNotEmpty &&
        selectedTopics.isNotEmpty &&
        qController.text.isNotEmpty &&
        aController.text.isNotEmpty &&
        bController.text.isNotEmpty &&
        cController.text.isNotEmpty &&
        dController.text.isNotEmpty &&
        correctAnswer != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Question"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SUBJECT DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSubject.isEmpty ? null : selectedSubject,
                  hint: const Text("Select a subject",
                      style: TextStyle(color: Colors.white54)),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value!;
                      selectedTopics.clear(); // reset topic list
                    });
                  },
                  items: topicsBySubject.keys
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TOPICS SELECTOR
            if (selectedSubject.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Topics",
                        style: TextStyle(color: Colors.white70)),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: selectedTopics
                          .map(
                            (topic) => Chip(
                          label: Text(topic),
                          backgroundColor: Colors.deepPurple,
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              selectedTopics.remove(topic);
                            });
                          },
                        ),
                      )
                          .toList(),
                    ),

                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: null,
                        hint: const Text("Add topic",
                            style: TextStyle(color: Colors.white54)),
                        dropdownColor: Colors.grey[900],
                        icon: const Icon(Icons.add, color: Colors.white),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          if (value != null &&
                              !selectedTopics.contains(value)) {
                            setState(() {
                              selectedTopics.add(value);
                            });
                          }
                        },
                        items: topicsBySubject[selectedSubject]!
                            .map(
                              (topic) => DropdownMenuItem(
                            value: topic,
                            child: Text(topic),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // QUESTION INPUT
            _inputBox("question", qController),

            const SizedBox(height: 15),

            // OPTIONS
            _optionInput("A", aController),
            _optionInput("B", bController),
            _optionInput("C", cController),
            _optionInput("D", dController),

            const SizedBox(height: 25),

            // ASSIGN CORRECT ANSWER BUTTON
            ElevatedButton(
              onPressed: () async {
                String? selected = await _selectAnswerDialog(context);
                if (selected != null) {
                  setState(() => correctAnswer = selected);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                correctAnswer == null ? Colors.grey : Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                correctAnswer == null
                    ? "Assign correct answer"
                    : "Correct answer: $correctAnswer",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 25),

            // CONTINUE BUTTON
            ElevatedButton(
              onPressed: isAllFilled ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isAllFilled ? Colors.deepPurple : Colors.grey[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Continue",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _inputBox(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  // option input with label A/B/C/D
  Widget _optionInput(
      String label, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white)),
          child: Text(label,
              style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "options",
                  hintStyle: TextStyle(color: Colors.white38)),
            ),
          ),
        ),
      ],
    );
  }

  // radio-style answer selection
  Future<String?> _selectAnswerDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Select the correct answer",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["A", "B", "C", "D"]
                .map(
                  (opt) => RadioListTile<String>(
                value: opt,
                groupValue: correctAnswer,
                activeColor: Colors.deepPurple,
                title: Text(opt, style: const TextStyle(color: Colors.white)),
                onChanged: (_) {
                  Navigator.pop(context, opt);
                },
              ),
            )
                .toList(),
          ),
        );
      },
    );
  }
}
