import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Reddit/services/api.dart';
import 'package:dio/dio.dart';

class ClusterDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cluster;

  const ClusterDetailsPage({super.key, required this.cluster});

  @override
  State<ClusterDetailsPage> createState() => _ClusterDetailsPageState();
}

class _ClusterDetailsPageState extends State<ClusterDetailsPage> {
  List notes = [];
  bool loading = true;

  // 🔥 NEW: selection state
  bool _selectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final res =
      await Api().get("/clusters/${widget.cluster["id"]}/notes");
      setState(() {
        notes = res["data"] ?? [];
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading notes: $e");
    }
  }

  // ================= UPLOAD =================
  Future<void> uploadPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
      withData: true, // required for web
    );

    if (result == null) return;

    final picked = result.files.single;

    try {
      final form = FormData();

      // 🔥 ALWAYS add cluster_id as STRING
      form.fields.add(
        MapEntry("cluster_id", widget.cluster["id"].toString()),
      );
      form.fields.add(
        MapEntry("title", picked.name),
      );

      if (picked.bytes != null) {
        // Web
        form.files.add(
          MapEntry(
            "pdf",
            MultipartFile.fromBytes(
              picked.bytes!,
              filename: picked.name,
            ),
          ),
        );
      } else if (picked.path != null) {
        // Mobile
        form.files.add(
          MapEntry(
            "pdf",
            await MultipartFile.fromFile(
              picked.path!,
              filename: picked.name,
            ),
          ),
        );
      } else {
        throw Exception("Unable to read selected file");
      }

      await Api().postMultipart(
        "/clusters/upload",
        formData: form,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload successful")),
      );

      await loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }


  // ================= DELETE NOTES =================
  void _confirmDeleteNotes() {
    if (_selectedNoteIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete notes"),
        content: Text(
          "Delete ${_selectedNoteIds.length} selected file(s)?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              // 🔥 backend call will be added later
              // for now just update UI
              setState(() {
                notes.removeWhere(
                      (n) => _selectedNoteIds.contains(n["_id"]),
                );
                _selectedNoteIds.clear();
                _selectionMode = false;
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cluster["name"]),
        leading: IconButton(
          icon: Icon(
            _selectionMode ? Icons.close : Icons.arrow_back,
          ),
          onPressed: () {
            if (_selectionMode) {
              setState(() {
                _selectionMode = false;
                _selectedNoteIds.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _selectionMode ? Icons.check : Icons.delete,
              color: _selectionMode ? Colors.green : Colors.red,
            ),
            onPressed: () {
              if (!_selectionMode) {
                setState(() {
                  _selectionMode = true;
                });
              } else {
                _confirmDeleteNotes();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadPDF,
        child: const Icon(Icons.upload_file),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text("No notes uploaded yet"))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, i) {
          final n = notes[i];
          final id = n["_id"];
          final selected = _selectedNoteIds.contains(id);

          return InkWell(
            onTap: _selectionMode
                ? () {
              setState(() {
                selected
                    ? _selectedNoteIds.remove(id)
                    : _selectedNoteIds.add(id);
              });
            }
                : null,
            child: Card(
              color: selected
                  ? Colors.red.withOpacity(0.15)
                  : null,
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(n["title"] ?? "Untitled"),
                subtitle: Text(
                  "Tags: ${(n["tags"] ?? []).join(", ")}",
                ),
                trailing: !_selectionMode
                    ? IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: download
                  },
                )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
