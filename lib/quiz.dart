import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Reddit/makeQ.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<String> subjects = [
    "Operating Systems",
    "DBMS",
    "Data Structures",
    "Computer Networks",
    "Cloud Computing",
  ];

  final Map<String, List<String>> topicsBySubject = {
    "Operating Systems": [
      "Processes",
      "Threads",
      "Scheduling",
      "Deadlocks",
      "Memory Management",
      "File Systems",
    ],
    "DBMS": [
      "SQL",
      "ER Model",
      "Normalization",
      "Transactions",
      "Joins",
    ],
    "Data Structures": [
      "Arrays",
      "Linked Lists",
      "Stacks",
      "Queues",
      "Trees",
      "Graphs"
    ],
    "Computer Networks": [
      "OSI Model",
      "TCP/IP",
      "Routing",
      "IP Addressing",
      "Sockets",
    ],
    "Cloud Computing": [
      "Virtualization",
      "Docker",
      "Kubernetes",
      "AWS Basics",
      "Load Balancing"
    ]
  };

  List<Map<String, dynamic>> tableRows = [];

  void addRow() {
    setState(() {
      tableRows.add({
        "subject": "",
        "topics": <String>[],
        "date": "",
        "perday": "",
        "needed": "",
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      tableRows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Study Planner"),
        backgroundColor: Colors.black,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addRow,
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddQuestionPage()),
                    );
                  },
                  child: const Text("Add questions"),
                ),
                OutlinedButton(
                    onPressed: () {},
                    child: const Text("Take quiz")
                ),
              ],
            ),

            const SizedBox(height: 10),

            Center(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Your timetable"),
              ),
            ),

            const SizedBox(height: 20),

            // HEADER
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
              child: const Row(
                children: [
                  Expanded(child: Text("Subject")),
                  Expanded(child: Text("Topics")),
                  Expanded(child: Text("Comp Date")),
                  Expanded(child: Text("Hrs / Day")),
                  Expanded(child: Text("Hrs Needed")),
                  SizedBox(width: 40),
                ],
              ),
            ),

            // BODY
            Column(
              children: List.generate(tableRows.length, (index) {
                var row = tableRows[index];

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.grey[900],
                            hint: const Text("Select", style: TextStyle(color: Colors.white38)),
                            value: row["subject"].isEmpty ? null : row["subject"],
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                row["subject"] = value!;
                                row["topics"].clear();
                              });
                            },
                            items: subjects
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                                .toList(),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              row["topics"].isEmpty
                                  ? const Text("Topic", style: TextStyle(color: Colors.white38))
                                  : Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: row["topics"]
                                    .map<Widget>((topic) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(topic,
                                      style: const TextStyle(color: Colors.white)),
                                ))
                                    .toList(),
                              ),

                              const SizedBox(height: 4),

                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.grey[900],
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  value: null,
                                  hint: const Text("Select topic", style: TextStyle(color: Colors.white54)),
                                  style: const TextStyle(color: Colors.white),

                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        if (!row["topics"].contains(value)) {
                                          row["topics"].add(value);
                                        }
                                      });
                                    }
                                  },

                                  items: (topicsBySubject[row["subject"]] ?? [])
                                      .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => row["date"] = v,
                          decoration: const InputDecoration(
                            hintText: "dd/mm",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // CHANGED: HOURS PER DAY
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (v) => row["perday"] = v,
                          decoration: const InputDecoration(
                            hintText: "0",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (v) => row["needed"] = v,
                          decoration: const InputDecoration(
                            hintText: "0",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () => removeRow(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
