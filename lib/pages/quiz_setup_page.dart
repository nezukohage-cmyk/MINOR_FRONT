import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';
import 'package:Reddit/pages/quiz_questions_page.dart';

class QuizSetupPage extends StatefulWidget {
  final int semester;
  const QuizSetupPage({super.key, required this.semester});

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends State<QuizSetupPage> {
  final _formKey = GlobalKey<FormState>();

  // ===============================
  // STATE
  // ===============================
  final Set<String> _selectedSubjects = {};                 // SUBJECT NAMES
  final Map<String, Set<String>> _selectedTopics = {};      // subjectName -> topicNames

  // ===============================
  // TAG DATA
  // ===============================
  final List<Map<String, dynamic>> _subjects = [];
  final List<Map<String, dynamic>> _topics = [];

  // name -> id (needed for topic filtering)
  final Map<String, String> _subjectNameToId = {};

  // ===============================
  // CONTROLLERS
  // ===============================
  final TextEditingController _countCtrl = TextEditingController(text: "10");
  final TextEditingController _timeCtrl = TextEditingController(text: "15");

  bool _loading = false;

  // ===============================
  // INIT
  // ===============================
  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  // ===============================
  // LOAD SUBJECTS & TOPICS
  // ===============================
  Future<void> _loadTags() async {
    try {
      final res = await Api().get("/tags/");
      final data = List<Map<String, dynamic>>.from(res["data"] ?? []);

      _subjects.clear();
      _topics.clear();
      _subjectNameToId.clear();

      for (final t in data) {
        if (t["type"] == "subject") {
          _subjects.add(t);
          _subjectNameToId[t["name"]] = t["id"];
        } else if (t["type"] == "topic") {
          _topics.add(t);
        }
      }

      setState(() {});
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load subjects/topics")),
      );
    }
  }

  // ===============================
  // START QUIZ
  // ===============================
  Future<void> _startQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one subject")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final questionCount = int.parse(_countCtrl.text);
      final timeMinutes = int.parse(_timeCtrl.text);

      // Build backend payload
      final Map<String, int> count = {};
      final Map<String, List<String>> topics = {};

      for (final subject in _selectedSubjects) {
        count[subject] = questionCount;

        final selected = _selectedTopics[subject];
        if (selected != null && selected.isNotEmpty) {
          topics[subject] = selected.toList();
        }
      }

      final payload = {
        "subjects": _selectedSubjects.toList(),
        "count": count,
        "topics": topics,
      };

      // DEBUG (safe to remove later)
      debugPrint("QUIZ START PAYLOAD => ${jsonEncode(payload)}");

      final res = await Api().postJson("/quiz/start", body: payload);

      if (res["quiz_id"] == null || res["questions"] == null) {
        throw Exception("Invalid quiz start response");
      }

      final quizId = res["quiz_id"];
      final total = res["total_questions"] ?? 0;

      final rawQuestions = List<Map<String, dynamic>>.from(res["questions"]);
      final questions = rawQuestions.map((q) {
        return {
          "id": (q["_id"] ?? q["id"]).toString(),
          "text": q["text"],
          "options": List<String>.from(q["options"] ?? []),
        };
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizQuestionsPage(
            quizId: quizId,
            questions: questions,
            totalAllowed: total,
            timeLimitMinutes: timeMinutes,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    const themeBlue = Color(0xFF2E3A8C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: themeBlue,
        elevation: 1,
        title: Text("Quiz Setup — Sem ${widget.semester}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ================= SUBJECTS =================
                const Text("Choose Subjects", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _subjects.map((s) {
                    final name = s["name"];
                    final selected = _selectedSubjects.contains(name);

                    return FilterChip(
                      label: Text(name),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedSubjects.add(name);
                            _selectedTopics[name] = {};
                          } else {
                            _selectedSubjects.remove(name);
                            _selectedTopics.remove(name);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                // ================= TOPICS =================
                if (_selectedSubjects.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("Select Topics", style: TextStyle(fontWeight: FontWeight.bold)),

                  ..._selectedSubjects.map((subjectName) {
                    final subjectId = _subjectNameToId[subjectName];

                    final relatedTopics = _topics.where((t) {
                      final parents = List<String>.from(t["parent_subjects"] ?? []);
                      return subjectId != null && parents.contains(subjectId);
                    }).toList();

                    if (relatedTopics.isEmpty) return const SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(subjectName, style: const TextStyle(fontWeight: FontWeight.w600)),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: relatedTopics.map((t) {
                            final topicName = t["name"];
                            final selected = _selectedTopics[subjectName]!.contains(topicName);

                            return FilterChip(
                              label: Text(topicName),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  v
                                      ? _selectedTopics[subjectName]!.add(topicName)
                                      : _selectedTopics[subjectName]!.remove(topicName);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
                ],

                const SizedBox(height: 20),

                // ================= COUNT =================
                const Text("Number of questions"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _countCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => int.tryParse(v ?? "") == null ? "Invalid number" : null,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),

                const SizedBox(height: 16),

                // ================= TIME =================
                const Text("Time (minutes)"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _timeCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => int.tryParse(v ?? "") == null ? "Invalid time" : null,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _loading ? null : _startQuiz,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Start Quiz", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }
}
