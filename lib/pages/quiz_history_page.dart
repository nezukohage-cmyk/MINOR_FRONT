import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Reddit/services/api.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await Api().get("/quiz/history");
      final data = List<Map<String, dynamic>>.from(res["data"] ?? []);
      setState(() {
        _history = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load quiz history")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return const Center(
        child: Text("No quizzes taken yet"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, i) {
        final q = _history[i];

        final startedAt = DateTime.tryParse(q["started_at"] ?? "");
        final submittedAt = DateTime.tryParse(q["submitted_at"] ?? "");

        final total = q["served_questions"] ?? 0;

        final score = q["score"] ?? 0;

        final subjectNames =
            (q["requested_count"] as Map?)?.keys.join(", ") ?? "N/A";

        final dateStr = startedAt != null
            ? DateFormat("dd MMM yyyy, hh:mm a").format(startedAt)
            : "Unknown date";

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectNames,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text("Score: $score / $total"),
                Text("Date: $dateStr"),

                if (startedAt != null && submittedAt != null)
                  Text(
                    "Time Taken: ${submittedAt.difference(startedAt).inSeconds}s",
                    style: const TextStyle(color: Colors.black54),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
