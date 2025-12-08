
import 'package:flutter/material.dart';
import 'package:Reddit/homefeed.dart';

class Cold extends StatefulWidget {
  const Cold({super.key});

  @override
  State<Cold> createState() => _ColdState();
}

class _ColdState extends State<Cold> {
  Set<String> selected = {};

  final Map<String, List<String>> categories = {
    "Study Management": [
      "Upload Notes",
      "Smart Rescheduling",
      "Topic Reminders",
      "Time Estimator"
    ],
    "Practice & Questions": [
      "Add PYQs",
      "Question Sets",
      "Weak Topic Insights"
    ],

    "DSA": [
      "DSA",
      "Linked list"
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Goals", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Pick things you'd like to see in your home feed.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: entry.value.map((item) {
                              final isSelected = selected.contains(item);
                              return FilterChip(
                                label: Text(item, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                                selected: isSelected,
                                selectedColor: Colors.white,
                                backgroundColor: Colors.grey[800],
                                onSelected: (val) {
                                  setState(() {
                                    if (val) selected.add(item); else selected.remove(item);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(color: Colors.white30, thickness: 1),
            const SizedBox(height: 5),
            Text("${selected.length} of 1 selected", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeFeed()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected.isEmpty ? Colors.grey : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

