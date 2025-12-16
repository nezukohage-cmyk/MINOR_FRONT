import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Reddit/services/api.dart';

class QuizDetailsPage extends StatefulWidget {
  final String quizId;
  const QuizDetailsPage({super.key, required this.quizId});

  @override
  State<QuizDetailsPage> createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final res = await Api().get("/quiz/${widget.quizId}/details");
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load quiz details")));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeBlue = Color(0xFF2E3A8C);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return const Scaffold(
        body: Center(child: Text("No data available")),
      );
    }

    final score = _data!["score"] ?? 0;
    final total = _data!["total"] ?? 0;
    final percentage = (_data!["percentage"] ?? 0).toDouble();
    final accuracy = (_data!["accuracy"] ?? 0).toDouble();
    final dateStr = _data!["date"];
    final date = dateStr != null
        ? DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.parse(dateStr))
        : "N/A";

    final weakTopics = Map<String, dynamic>.from(_data!["weak_topics"] ?? {});
    final trends = List<Map<String, dynamic>>.from(_data!["trend"] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: themeBlue,
        elevation: 1,
        title: const Text("Quiz Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ---------------- SUMMARY ----------------
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _row("Score", "$score / $total"),
                _row("Accuracy", "${accuracy.toStringAsFixed(2)}%"),
                _row("Percentage", "${percentage.toStringAsFixed(1)}%"),
                _row("Attempted on", date),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- WEAK TOPICS (CURRENT) ----------------
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Weak Topics (This Quiz)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                weakTopics.isEmpty
                    ? const Text("No weak topics 🎉")
                    : Wrap(
                  spacing: 8,
                  children: weakTopics.keys
                      .map((t) => Chip(
                    label: Text(t),
                    backgroundColor: Colors.red.shade100,
                  ))
                      .toList(),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- TREND (LAST 5 QUIZZES) ----------------
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Weak Topic Trend (Last 5 Quizzes)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                trends.isEmpty
                    ? const Text("Not enough data yet")
                    : Column(
                  children: trends.map((t) {
                    final trend = t["trend"];
                    Color color = Colors.green;
                    if (trend == "weak") color = Colors.red;
                    if (trend == "needs practice") color = Colors.orange;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t["topic"]),
                      trailing: Chip(
                        label: Text(trend),
                        backgroundColor: color.withOpacity(0.15),
                        labelStyle: TextStyle(color: color),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child:
              Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(v),
        ],
      ),
    );
  }
}
