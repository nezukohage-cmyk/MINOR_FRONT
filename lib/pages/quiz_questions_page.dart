// lib/pages/quiz_questions_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';
import 'quiz_result_page.dart';

class QuizQuestionsPage extends StatefulWidget {
  final String quizId;
  final List<Map<String, dynamic>> questions;
  final int totalAllowed;
  final int timeLimitMinutes;

  const QuizQuestionsPage({
    super.key,
    required this.quizId,
    required this.questions,
    required this.totalAllowed,
    required this.timeLimitMinutes,
  });

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  late List<Map<String, dynamic>> _questions;
  final Map<String, String> _selectedAnswers = {}; // questionId -> selected option
  int _currentIndex = 0;

  // timer
  late int _remainingSeconds;
  Timer? _timer;
  bool _submitting = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _questions = List<Map<String, dynamic>>.from(widget.questions);
    _remainingSeconds = widget.timeLimitMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _onTimeUp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTimeUp() {
    // Auto submit answers if time's up
    _submitQuiz(auto: true);
  }

  void _selectAnswer(String qid, String option) {
    setState(() {
      _selectedAnswers[qid] = option;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // If user asked for more questions than currently loaded, ideally load more
      // For now, submit if last question reached
      _submitQuiz();
    }
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  Future<void> _submitQuiz({bool auto = false}) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final answers = _selectedAnswers.entries.map((e) {
      return {"question_id": e.key, "selected": e.value};
    }).toList();

    final body = {"quiz_id": widget.quizId, "answers": answers};
    try {
      final res = await Api().postJson("/quiz/submit", body: body);

      // Expected response: total, correct, wrong, score, details
      final total = res["total"] ?? res["data"]?["total"];
      final correct = res["correct"] ?? res["data"]?["correct"];
      final details = res["details"] ?? res["data"]?["details"];

      if (!mounted) return;
      // stop timer
      _timer?.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            total: total ?? 0,
            correct: correct ?? 0,
            details: (details is List) ? List<Map<String, dynamic>>.from(details) : [],
            quizId: widget.quizId,
          ),
        ),
      );
    } catch (e) {
      final msg = e.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit: $msg")));
      setState(() => _submitting = false);
      if (auto) {
        // If auto submit failed, just navigate back
        Navigator.of(context).maybePop();
      }
    }
  }

  Widget _buildOption(String qid, String option) {
    final selected = _selectedAnswers[qid] == option;
    return GestureDetector(
      onTap: () => _selectAnswer(qid, option),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E3A8C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
          boxShadow: selected ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))] : null,
        ),
        child: Text(
          option,
          style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final q = _questions[_currentIndex];
    final qid = (q["id"] ?? q["_id"] ?? "").toString();
    final text = (q["text"] ?? "").toString();
    final options = (q["options"] is List) ? List<String>.from(q["options"].map((e) => e.toString())) : <String>[];

    final minute = _remainingSeconds ~/ 60;
    final second = _remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text("$minute:${second.toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // progress
            Text("Question ${_currentIndex + 1} / ${_questions.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(text, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ...options.map((o) => _buildOption(qid, o)).toList(),
                ]),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _currentIndex == 0 ? null : _prev,
                  child: const Text("Previous"),
                ),
                Row(children: [
                  TextButton(
                    onPressed: () {
                      // clear selected for this question
                      setState(() {
                        _selectedAnswers.remove(qid);
                      });
                    },
                    child: const Text("Clear"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitting ? null : _next,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E3A8C)),
                    child: Text(_currentIndex == _questions.length - 1 ? "Submit" : "Next"),
                  ),
                ])
              ],
            )
          ],
        ),
      ),
    );
  }
}
