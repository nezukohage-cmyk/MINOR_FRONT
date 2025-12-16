// lib/pages/quiz_result_page.dart
import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int total;
  final int correct;
  final List<Map<String, dynamic>> details;
  final String quizId;

  const QuizResultPage({
    super.key,
    required this.total,
    required this.correct,
    required this.details,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    final wrong = total - correct;
    final percent = total > 0 ? (correct / total) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E3A8C),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Text("${percent.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF2E3A8C))),
                const SizedBox(height: 8),
                Text("Score: $correct / $total", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Wrong: $wrong", style: const TextStyle(color: Colors.red)),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          const Align(alignment: Alignment.centerLeft, child: Text("Question review", style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, i) {
                final d = details[i];
                final isCorrect = d["is_correct"] == true;
                return ListTile(
                  tileColor: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  title: Text(d["text"] ?? ""),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 6),
                    Text("Your answer: ${d['selected'] ?? '-'}"),
                    Text("Correct: ${d['correct'] ?? '-'}"),
                  ]),
                  trailing: Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
