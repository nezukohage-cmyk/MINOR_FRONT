// lib/pages/home_page.dart
import 'package:Reddit/pages/cluster_details_page.dart';
import 'package:Reddit/pages/quiz_setup_page.dart';
import 'package:Reddit/pages/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Reddit/services/api.dart';
import 'package:Reddit/pages/semester_selector.dart';
import 'package:Reddit/pages/quiz_page.dart';
import 'package:Reddit/pages/quiz_history_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _title = "Home";
  String _role = "student"; // default
  Widget _body = const HomeDashboard(role: "student");

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final r = prefs.getString("role") ?? "student";

    setState(() {
      _role = r;
      _body = HomeDashboard(role: r);
    });
  }

  void _openMenu(String id) {
    switch (id) {
      case 'notes':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotesPage(semester: 0),
          ),
        );
        break;



      case 'quiz_history':
        _body = const QuizHistoryPage();
        _title = "Quiz History";
        break;
      case 'quiz':
        _body = SemesterSelector(
          title: "Select Semester",
          onSelect: (sem) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizSetupPage(semester: sem),
              ),
            );
          },
        );
        break;


      case 'analysis':
        _body = const PlaceholderPage(label: "Analysis (Coming Soon)");
        _title = "Analysis";
        break;
      case 'todo':
        _body = const TodoPage();
        _title = "To-Do List";
        break;
      case 'clusters':
        _body = SemesterSelector(
          title: "Select Semester",
          onSelect: (sem) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClustersPage(semester: sem),
              ),
            );
          },
        );
        break;

      case 'summarizer':
        _body = const SummarizerPage();
        _title = "Summarizer";
        break;
      default:
        _body = HomeDashboard(role: _role);
        _title = "Home";
    }

    setState(() {});
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _title,
          style: const TextStyle(
            color: Color(0xFF2E3A8C),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A8C)),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                child: Text(
                  "Exam Buddy\n($_role mode)",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A8C),
                  ),
                ),
              ),

              if (_role == "admin") ...[
                _drawerItem(Icons.class_, "Manage clusters", () => _openMenu('clusters')),
                _drawerItem(Icons.upload_file, "Upload Notes", () => _openMenu('notes')),
                _drawerItem(Icons.people, "Student Management", () {}),
              ] else ...[
                _drawerItem(Icons.note, "My Notes", () => _openMenu('notes')),
                _drawerItem(Icons.class_, "clusters", () => _openMenu('clusters')),
                _drawerItem(Icons.quiz, "Quiz", () => _openMenu('quiz')),
              ],
              _drawerItem(Icons.history, "Quiz History", () => _openMenu('quiz_history')),

              _drawerItem(Icons.checklist, "To-Do", () => _openMenu('todo')),
              _drawerItem(Icons.summarize, "Summarizer", () => _openMenu('summarizer')),

              const Spacer(),
              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Log out"),
                onTap: () {
                  Api().clearToken();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),

      body: Padding(
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



class HomeDashboard extends StatelessWidget {
  final String role;
  const HomeDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final items = role == "admin"
        ? [
      _tile(context, Icons.class_, "Manage Classes", "clusters"),
      _tile(context, Icons.upload_file, "Upload Notes", "notes"),
      _tile(context, Icons.analytics, "Analysis", "analysis"),
    ]
        : [
      _tile(context, Icons.note, "My Notes", "notes"),
      _tile(context, Icons.class_, "clusters", "clusters"),
      _tile(context, Icons.quiz, "Quiz", "quiz"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Search clusters...",
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
          ),
        ),

        const SizedBox(height: 25),
        Text(
          "Quick Access • ${role.toUpperCase()}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),

        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String id) {
    return GestureDetector(
      onTap: () {
        final parent = context.findAncestorStateOfType<_HomePageState>();
        parent?._openMenu(id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Color(0xFF2E3A8C)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}





class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: const TextStyle(fontSize: 18)));
  }
}

// your existing NotesPage, TodoPage, SummarizerPage, ClassroomsPage remain unchanged
// paste them below...

// -------- My Notes (simple listing)
// Later: hook to GET /notes and show thumbnails + download button.
class NotesPage extends StatefulWidget {

  const NotesPage({super.key, required this.semester});
  final int semester;
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
    try {
      final res = await Api().get("/notes/saved");

      setState(() {
        _notes = List<Map<String, dynamic>>.from(res["data"] ?? []);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load notes: $e")),
      );
    }
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
            onTap: () async {
              final url = note["file_url"];
              if (url != null) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    final url = note["file_url"];
                    if (url != null) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    break;

                  case 'download':
                    final url = note["file_url"];
                    if (url != null) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    break;

                  case 'unsave':
                    await Api().postJson(
                      "/notes/unsave",
                      body: {"note_id": note["id"]},
                    );
                    await _loadNotes();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text("View")),
                PopupMenuItem(value: 'download', child: Text("Download")),
                PopupMenuItem(value: 'unsave', child: Text("Remove from My Notes")),
              ],
            ),
          ),
        );

      },
    );
  }
}

// -------- Classrooms (tile grid placeholder)
class ClustersPage extends StatefulWidget {
  //const ClustersPage({super.key});
  final int semester;
  const ClustersPage({Key? key, required this.semester}) : super(key: key);

  @override
  State<ClustersPage> createState() => _ClustersPageState();
}

class _ClustersPageState extends State<ClustersPage> {
  List<dynamic> clusters = [];

  @override
  void initState() {
    super.initState();
    loadClusters();
  }

  Future<void> loadClusters() async {
    try {
      final res = await Api().get(
        "/clusters?semester=${widget.semester}",
      );

      setState(() {
        clusters = List<Map<String, dynamic>>.from(res["data"] ?? []);
      });
    } catch (e) {
      debugPrint("Failed to load clusters: $e");
    }
  }



  void openCreateClusterDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create New Cluster"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Cluster Name"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();

              if (name.isEmpty) return;

              try {
                await Api().postJson(
                  "/clusters/create",
                  body: {
                    "name": name,
                    "description": desc,
                    "tags": [],
                    "semester": widget.semester,
                  },
                );

                Navigator.pop(ctx);
                loadClusters();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed: $e")),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final grid = clusters.isEmpty
        ? const Center(child: Text("No clusters yet"))
        : GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: clusters.map((c) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClusterDetailsPage(cluster: c),
              ),
            );
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(c["name"] ?? "Untitled",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(c["description"] ?? "",
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
          ),
        );

      }).toList(),
    );

    return Scaffold(
      body: grid,
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateClusterDialog,
        backgroundColor: const Color(0xFFFFB020),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

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
      final res = await Api().postJson("/chat/Summarize", body: {"text": text});
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
