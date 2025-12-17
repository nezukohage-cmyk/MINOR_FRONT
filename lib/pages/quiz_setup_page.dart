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
  // MULTI-SELECTION STATE
  // ===============================
  final Set<String> _selectedSubjects = {};
  final Map<String, Set<String>> _selectedTopics = {};

  // ===============================
  // DATA FROM BACKEND (/tags)
  // ===============================
  final List<Map<String, dynamic>> _subjects = [];
  final List<Map<String, dynamic>> _topics = [];

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

      for (final t in data) {
        if (t["type"] == "subject") {
          _subjects.add(t);
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

      // Build payload for backend
      final Map<String, int> count = {};
      final Map<String, List<String>> topics = {};

      for (final s in _selectedSubjects) {
        count[s] = questionCount;
        if (_selectedTopics[s] != null && _selectedTopics[s]!.isNotEmpty) {
          topics[s] = _selectedTopics[s]!.toList();
        }
      }

      final payload = {
        "subjects": _selectedSubjects.toList(),
        "count": count,
        "topics": topics,
      };

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
                    final id = s["name"];
                    final label = s["name"] ;
                    final selected = _selectedSubjects.contains(id);

                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedSubjects.add(id);
                            _selectedTopics[id] = {};
                          } else {
                            _selectedSubjects.remove(id);
                            _selectedTopics.remove(id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                // ================= TOPICS =================
                if (_selectedSubjects.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("Select Topics ", style: TextStyle(fontWeight: FontWeight.bold)),

                  ..._selectedSubjects.map((subj) {
                    final relatedTopics = _topics.where((t) {
                      final parents = List<String>.from(t["parent_subject"] ?? []);
                      return parents.contains(subj);
                    }).toList();

                    if (relatedTopics.isEmpty) return const SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          _subjects.firstWhere(
                                (s) => s["_id"] == subj,
                            orElse: () => const {"name": "name"},
                          )["name"],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: relatedTopics.map((t) {
                            final tid = t["name"];
                            final label = t["name"] ?? tid;
                            final selected = _selectedTopics[subj]!.contains(tid);

                            return FilterChip(
                              label: Text(label),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  v
                                      ? _selectedTopics[subj]!.add(tid)
                                      : _selectedTopics[subj]!.remove(tid);
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
                        : const Text("Start Quiz", style: TextStyle(fontSize: 16,color: Colors.white),),
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
