// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart'; // your Api wrapper

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _title = "Home";
  Widget _body = const HomeWelcome();

  void _openMenu(String id) {
    switch (id) {
      case 'notes':
        setState(() {
          _title = "My Notes";
          _body = const NotesPage();
        });
        break;
      case 'quiz':
        setState(() {
          _title = "Quiz";
          _body = const PlaceholderPage(label: "Quiz (placeholder)");
        });
        break;
      case 'analysis':
        setState(() {
          _title = "Analysis";
          _body = const PlaceholderPage(label: "Analysis (placeholder)");
        });
        break;
      case 'todo':
        setState(() {
          _title = "To-Do List";
          _body = const TodoPage();
        });
        break;
      case 'classrooms':
        setState(() {
          _title = "Classrooms";
          _body = const ClassroomsPage();
        });
        break;
      case 'summarizer':
        setState(() {
          _title = "Summarizer";
          _body = const SummarizerPage();
        });
        break;
      default:
        setState(() {
          _title = "Home";
          _body = const HomeWelcome();
        });
    }
    Navigator.of(context).pop(); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: const TextStyle(color: Color(0xFF2E3A8C), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E3A8C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF2E3A8C)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("exam buddy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E3A8C))),
                ),
              ),
              _drawerItem(Icons.note, "My Notes", () => _openMenu('notes')),
              _drawerItem(Icons.quiz, "Quiz (placeholder)", () => _openMenu('quiz')),
              _drawerItem(Icons.bar_chart, "Analysis (placeholder)", () => _openMenu('analysis')),
              _drawerItem(Icons.checklist, "To-Do List", () => _openMenu('todo')),
              _drawerItem(Icons.class_, "Classrooms", () => _openMenu('classrooms')),
              _drawerItem(Icons.summarize, "Summarizer", () => _openMenu('summarizer')),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Log out"),
                onTap: () {
                  // clear token and pop to login
                  Api().clearToken();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF3F4F6),
        padding: const EdgeInsets.all(18),
        child: _body,
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E3A8C)),
      title: Text(label),
      onTap: onTap,
    );
  }
}

// ----------------- Pages -----------------

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome to Classroom Lite\nUse the menu to navigate.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black54),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.black54)));
  }
}

// -------- My Notes (simple listing)
// Later: hook to GET /notes and show thumbnails + download button.
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}
class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // Placeholder: call Api().get("/notes") when backend is ready
    // final res = await Api().get("/notes");
    // Parse and setState(...)
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _notes = [
        {"id": "1", "title": "Lecture 1 - Algorithms.pdf"},
        {"id": "2", "title": "Lecture 2 - Data structures.pdf"},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_notes.isEmpty) {
      return const Center(child: Text("No notes saved yet."));
    }
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, i) {
        final note = _notes[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(note["title"] ?? "Untitled"),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: call Api.downloadBytes(url) and save file
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download placeholder")));
              },
            ),
          ),
        );
      },
    );
  }
}

// -------- Classrooms (tile grid placeholder)
class ClassroomsPage extends StatelessWidget {
  const ClassroomsPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Placeholder grid (later: fetch from /classrooms)
    final dummy = List.generate(8, (i) => "Class ${i + 1}");
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: dummy.map((t) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 80, decoration: BoxDecoration(color: Colors.blueGrey.shade100, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text("Instructor name", style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// -------- Todo Page (functional UI)
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}
class _TodoPageState extends State<TodoPage> {
  final _taskCtrl = TextEditingController();
  List<Map<String, dynamic>> _tasks = []; // {id, text}
  List<Map<String, dynamic>> _completed = [];

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      _tasks.insert(0, {"id": id, "text": text});
      _taskCtrl.clear();
    });
  }

  void _completeTask(String id) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t["id"] == id);
      if (idx != -1) {
        final t = _tasks.removeAt(idx);
        _completed.insert(0, t);
      }
    });
  }

  void _undoComplete(String id) {
    setState(() {
      final idx = _completed.indexWhere((t) => t["id"] == id);
      if (idx != -1) {
        final t = _completed.removeAt(idx);
        _tasks.insert(0, t);
      }
    });
  }

  void _deleteCompleted(String id) {
    setState(() {
      _completed.removeWhere((t) => t["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // input row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskCtrl,
                  decoration: const InputDecoration(
                    hintText: "Add a task...",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addTask, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB020)), child: const Text("Add"))
            ],
          ),
        ),

        // tasks list
        Expanded(
          child: _tasks.isEmpty
              ? const Center(child: Text("No tasks - add one above"))
              : ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, i) {
              final t = _tasks[i];
              return ListTile(
                title: Text(t["text"], style: const TextStyle(fontSize: 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () => _completeTask(t["id"]),
                ),
              );
            },
          ),
        ),

        // completed
        ExpansionTile(
          title: Text("Completed (${_completed.length})"),
          children: _completed
              .map((c) => ListTile(
            title: Text(c["text"], style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black45)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.undo), onPressed: () => _undoComplete(c["id"])),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCompleted(c["id"])),
            ]),
          ))
              .toList(),
        ),
      ],
    );
  }
}

// -------- Summarizer Page (simple file/text upload)
class SummarizerPage extends StatefulWidget {
  const SummarizerPage({super.key});
  @override
  State<SummarizerPage> createState() => _SummarizerPageState();
}
class _SummarizerPageState extends State<SummarizerPage> {
  final _textCtrl = TextEditingController();
  String _summary = "";
  bool _loading = false;

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);

    try {
      // Call your backend summarizer endpoint
      final res = await Api().postJson("/summarize", body: {"text": text});
      setState(() {
        _summary = (res["summary"] ?? "").toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: _textCtrl,
        minLines: 6,
        maxLines: 12,
        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Paste text to summarize"),
      ),
      const SizedBox(height: 10),
      Row(children: [
        ElevatedButton(onPressed: _loading ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB020)), child: const Text("Summarize")),
        const SizedBox(width: 12),
        if (_loading) const CircularProgressIndicator(),
      ]),
      const SizedBox(height: 12),
      if (_summary.isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_summary),
          ),
        ),
    ]);
  }
}
