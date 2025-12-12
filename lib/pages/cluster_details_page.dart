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

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final res =
      await Api().get("/clusters/${widget.cluster["_id"]}/notes");
      setState(() {
        notes = res["data"] ?? [];
        loading = false;
      });
    } catch (e) {
      print("Error loading notes: $e");
    }
  }

  Future<void> uploadPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
      withData: true, // required for web to provide bytes
    );

    if (result == null) return;

    final picked = result.files.single;

    try {
      // Build FormData (web: use bytes, mobile: use path)
      FormData form;
      if (picked.bytes != null) {
        // Web (or any platform where we have bytes)
        final mf = MultipartFile.fromBytes(
          picked.bytes!,
          filename: picked.name,
        );

        form = FormData.fromMap({
          "cluster_id": widget.cluster["_id"],
          "title": picked.name,
          "pdf": mf,
        });
      } else if (picked.path != null) {
        // Mobile (path available)
        form = FormData.fromMap({
          "cluster_id": widget.cluster["_id"],
          "title": picked.name,
          // Dio will convert this to multipart file
          "pdf": await MultipartFile.fromFile(picked.path!, filename: picked.name),
        });
      } else {
        throw Exception("Unable to read selected file (no bytes and no path).");
      }

      // Call API — note: path must match your server route (e.g. "/clusters/upload")
      final res = await Api().postMultipart("/clusters/upload", formData: form);

      // check server response
      if (res["error"] != null) {
        throw Exception(res["error"]);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload successful")));
      await loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }


  Future<void> deleteCluster() async {
    try {
      await Api().delete("/clusters/${widget.cluster["_id"]}");
      Navigator.pop(context);
    } catch (e) {
      print("Failed to delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cluster["name"]),
        actions: [
          IconButton(
            onPressed: deleteCluster,
            icon: const Icon(Icons.delete, color: Colors.red),
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
          return Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(n["title"]),
              subtitle: Text("Tags: ${n["tags"].join(", ")}"),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // TODO: Download PDF
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
