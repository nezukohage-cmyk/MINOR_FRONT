// -------- TODO PAGE WITH BACKEND + DEADLINE + DATE PICKER -------- //

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // -------------------------------
  // STATE
  // -------------------------------
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _tasks = [];
  bool _loading = false;

  // For Add Task Dialog
  final TextEditingController _taskCtrl = TextEditingController();
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // -------------------------------
  // FETCH TASKS FROM BACKEND
  // -------------------------------
  Future<void> _fetchTasks() async {
    setState(() => _loading = true);

    final dateStr = DateFormat("yyyy-MM-dd").format(_selectedDate);

    try {
      final res = await Api().get("/todo/date/$dateStr");

      setState(() {
        _tasks = res["tasks"] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  // -------------------------------
  // ADD TASK (BACKEND)
  // -------------------------------
  Future<void> _openAddTaskDialog() async {
    _taskCtrl.clear();
    _deadline = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text("Add Task",style: TextStyle(color: Colors.white),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskCtrl,
                  decoration: const InputDecoration(
                    labelText: "Task",
                  ),
                ),

                const SizedBox(height: 16),

                // DEADLINE PICKER (OPTIONAL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Deadline (optional)"),
                    TextButton(
                      child: Text(_deadline == null
                          ? "Select"
                          : DateFormat("MMM d, h:mm a").format(_deadline!)),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate == null) return;

                        final pickedTime = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime == null) return;

                        final deadlineDT = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        setStateDialog(() => _deadline = deadlineDT);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final taskText = _taskCtrl.text.trim();
                  if (taskText.isEmpty) return;

                  final dateStr = DateFormat("yyyy-MM-dd").format(_selectedDate);

                  try {
                    await Api().postJson(
                      "/todo/create",
                      body: {
                        "task": taskText,
                        "date": dateStr,
                        "deadline": _deadline?.toIso8601String(),

                      },
                    );

                    Navigator.pop(ctx);
                    _fetchTasks();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }

  // -------------------------------
  // TOGGLE TASK DONE STATUS
  // -------------------------------
  Future<void> _toggleTask(String id) async {
    try {
      await Api().post("/todo/$id/toggle");
      _fetchTasks();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // -------------------------------
  // DATE PICKER
  // -------------------------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchTasks();
    }
  }

  // -------------------------------
  // UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("MMM d, yyyy").format(_selectedDate);

    return Column(
      children: [
        // DATE PICKER BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tasks for $dateLabel",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _pickDate,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? const Center(child: Text("No tasks for this day."))
              : ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, i) {
              final t = _tasks[i];
              final bool done = t["done"] == true;
              final deadline = t["deadline"];

              return Card(
                child: ListTile(
                  title: Text(
                    t["task"],
                    style: TextStyle(
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: done ? Colors.grey : Colors.black,
                    ),
                  ),

                  subtitle: deadline != null
                      ? Text(
                    "Deadline: ${DateFormat("MMM d, h:mm a").format(DateTime.parse(deadline))}",
                    style: const TextStyle(fontSize: 12),
                  )
                      : null,

                  trailing: IconButton(
                    icon: Icon(
                      done
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: done ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleTask(t["id"]),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ADD TASK BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openAddTaskDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E3A8C),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Add Task",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
