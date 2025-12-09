import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:Reddit/HomeFeed.dart';

class UploadNotePage extends StatefulWidget {
  const UploadNotePage({super.key});

  @override
  State<UploadNotePage> createState() => _UploadNotePageState();
}

class _UploadNotePageState extends State<UploadNotePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // Hard-coded subjects + topics
  final Map<String, List<String>> topicsBySubject = {
    "DBMS": [
      "ER Model",
      "Normalization",
      "Transactions",
      "Indexing",
      "Queries",
      "Joins"
    ],
    "OS": [
      "Scheduling",
      "Memory Management",
      "Deadlocks",
      "Paging",
      "Processes",
      "Concurrency"
    ],
    "Java": [
      "OOP Concepts",
      "Collections",
      "Exception Handling",
      "Streams",
      "Threads",
      "JVM Internals"
    ],
    "Micro Controller": [
      "Architecture",
      "Timers",
      "Interrupts",
      "GPIO",
      "Communication Protocols",
      "Memory Mapping"
    ]
  };

  // Only community
  final List<String> communities = ["SDMCET"];

  String? selectedCommunity;
  String? selectedSubject;
  String? selectedTopic;

  /// For web we use PlatformFile, for mobile File
  List<PlatformFile> webFiles = [];
  List<File> mobileFiles = [];

  bool loading = false;

  // Change this to your backend host when testing on device/web.
  // You previously reported backend IP 192.168.29.143 — use that if testing on device or web:
  static const String baseUrl = "http://172.20.10.7:8080";

  // Pick multiple files (withData true required for Web)
  Future<void> pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (res == null) return;

    setState(() {
      if (kIsWeb) {
        webFiles = res.files;
      } else {
        mobileFiles =
            res.paths.whereType<String>().map((path) => File(path)).toList();
      }
    });
  }

  bool _isImageName(String filename) {
    final ext = p.extension(filename).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(ext);
  }

  Future<void> uploadNote() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) return _err("Title is required");
    if (selectedSubject == null) return _err("Select a subject");
    if (selectedTopic == null) return _err("Select a topic");
    if (kIsWeb && webFiles.isEmpty) return _err("Select at least one file");
    if (!kIsWeb && mobileFiles.isEmpty) return _err("Select at least one file");

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final uri = Uri.parse("$baseUrl/notes/upload");
      final request = http.MultipartRequest("POST", uri);

      if (token.isNotEmpty) request.headers["Authorization"] = "Bearer $token";
      print("TOKEN USED FOR UPLOAD = $token");
      request.fields["subjects"] = selectedSubject!;
      request.fields["topics"] = selectedTopic!;
      request.fields["text"] = title;
      request.fields["description"] = _descController.text.trim();
      request.fields["moderation_status"] = "approved";

      if (kIsWeb) {
        for (final f in webFiles) {
          final multipart = http.MultipartFile.fromBytes(
            "files",
            f.bytes!, // required when withData:true
            filename: f.name,
          );
          request.files.add(multipart);
        }
      } else {
        for (final file in mobileFiles) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipart = http.MultipartFile(
            "files",
            stream,
            length,
            filename: p.basename(file.path),
          );
          request.files.add(multipart);
        }
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      setState(() => loading = false);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _success("Uploaded successfully");
        //println("Uploaded URL:", uploadedUrl);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFeed()),
        );
      } else {
        _err("Upload failed: ${resp.statusCode} — ${resp.body}");
      }
    } catch (e) {
      setState(() => loading = false);
      // XMLHttpRequest error commonly appears for CORS/host issues on Web
      _err("Upload error: $e");
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _success(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // build lists
    final subjectItems = topicsBySubject.keys.toList();
    final topicItems =
    selectedSubject == null ? <String>[] : topicsBySubject[selectedSubject!]!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Upload Note"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCommunity ?? communities.first,
              items: communities
                  .map<DropdownMenuItem<String>>((c) =>
                  DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCommunity = v),
              decoration: const InputDecoration(
                labelText: "Community",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSubject,
                    items: subjectItems
                        .map<DropdownMenuItem<String>>((s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedSubject = v;
                      selectedTopic = null;
                    }),
                    decoration: const InputDecoration(
                      labelText: "Subject",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTopic,
                    items: topicItems
                        .map<DropdownMenuItem<String>>((t) =>
                        DropdownMenuItem<String>(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedTopic = v),
                    decoration: const InputDecoration(
                      labelText: "Topic",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Description (optional)",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickFiles,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildFilePreview(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : uploadNote,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Continue", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final isEmpty = kIsWeb ? webFiles.isEmpty : mobileFiles.isEmpty;
    if (isEmpty) {
      return const Center(
        child: Text("Upload files (images/pdf)",
            style: TextStyle(color: Colors.white70)),
      );
    }

    final count = kIsWeb ? webFiles.length : mobileFiles.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: count,
      itemBuilder: (_, i) {
        final name = kIsWeb ? webFiles[i].name : p.basename(mobileFiles[i].path);
        final isImg = _isImageName(name);

        return Container(
          width: 180,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(isImg ? Icons.image : Icons.picture_as_pdf,
                  color: Colors.white70, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (kIsWeb) {
                      webFiles.removeAt(i);
                    } else {
                      mobileFiles.removeAt(i);
                    }
                  });
                },
                child: const Icon(Icons.close, color: Colors.white70),
              )
            ],
          ),
        );
      },
    );
  }
}
