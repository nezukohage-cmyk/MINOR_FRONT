// // lib/pages/upload_note.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;
// import 'package:Reddit/services/moderation.dart';
// import 'package:Reddit/HomeFeed.dart';
// import 'package:http_parser/http_parser.dart';
//
//
// class UploadNotePage extends StatefulWidget {
//   const UploadNotePage({super.key});
//
//   @override
//   State<UploadNotePage> createState() => _UploadNotePageState();
// }
//
// class _UploadNotePageState extends State<UploadNotePage> {
//   final _titleController = TextEditingController();
//   final _descController = TextEditingController();
//
//   // local subject -> topics mapping (Option B). Edit as needed.
//   final Map<String, List<String>> topicsBySubject = {
//     "DSA": ["Linked List", "Trees", "Recursion"],
//     "OS": ["Paging", "Scheduling", "Concurrency"],
//     "DBMS": ["ER Model", "Normalization"],
//     "Maths": ["Calculus", "Linear Algebra"]
//   };
//
//   // communities list - can fetch from API later, currently example
//   final List<String> communities = ["SDMCET", "Global", "Local College"];
//
//   String? selectedCommunity;
//   String? selectedSubject;
//   String? selectedTopic;
//   File? selectedFile;
//   bool loading = false;
//
//   // moderation service (images only)
//   final ModerationService _moderation = ModerationService();
//
//   @override
//   void initState() {
//     super.initState();
//     // pre-load moderation model (non-blocking)
//     _moderation.loadModel().catchError((e) {
//       // model may not be available on web; ignore failure here
//       // print("Moderation load failed: $e");
//     });
//   }
//
//   // Helper: open file picker
//   Future<void> pickFile() async {
//     final res = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: [
//         'jpg', 'jpeg', 'png', // images
//         'pdf', 'doc', 'docx'  // documents
//       ],
//       withData: false,
//     );
//     if (res == null) return;
//     final path = res.files.single.path;
//     if (path == null) return;
//     setState(() {
//       selectedFile = File(path);
//     });
//   }
//
//   bool _isImage(File f) {
//     final ext = p.extension(f.path).toLowerCase();
//     return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
//   }
//
//   // Upload function — multipart
//   Future<void> uploadNote() async {
//     // validations
//     final title = _titleController.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
//       return;
//     }
//     if (selectedSubject == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a subject')));
//       return;
//     }
//     if (selectedTopic == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a topic')));
//       return;
//     }
//     if (selectedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a file to upload')));
//       return;
//     }
//
//     setState(() { loading = true; });
//
//     // If image — run moderation
//     if (_isImage(selectedFile!)) {
//       try {
//         if (!_moderation.isReady) {
//           await _moderation.loadModel();
//         }
//         final result = await _moderation.classify(selectedFile!);
//         final pageScore = result["Page"] ?? 0.0;
//         // block if not study
//         if (pageScore < 0.70) {
//           setState(() { loading = false; });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Upload rejected: Not related to studies.")),
//           );
//           return;
//         }
//       } catch (e) {
//         // If moderation fails for any reason, allow upload but warn
//         // (You can change to block instead)
//         // print("Moderation error: $e");
//       }
//     }
//
//     // Prepare multipart request
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       final uri = Uri.parse('http://localhost:8080/notes/upload'); // adjust if different
//       final request = http.MultipartRequest('POST', uri);
//
//       // Authorization
//       if (token.isNotEmpty) {
//         request.headers['Authorization'] = 'Bearer $token';
//       }
//
//       // required singular keys for Cloudinary path (as backend expects)
//       request.fields['subject'] = selectedSubject!;
//       request.fields['topic'] = selectedTopic!;
//
//       // plural keys (arrays) to store to DB - we add them as repeated fields
//       request.fields['subjects'] = selectedSubject!;
//       request.fields['topics'] = selectedTopic!;
//
//       // optional: title + description saved in text field 'text'
//       request.fields['text'] = title;
//       request.fields['description'] = _descController.text.trim();
//
//       // moderation_status: directly set to approved if image passed moderation
//       // For simplicity: if image passed moderation -> approve else pending
//       if (_isImage(selectedFile!)) {
//         request.fields['moderation_status'] = 'approved';
//       } else {
//         // For docs/pdfs, keep pending (or you can set approved)
//         request.fields['moderation_status'] = 'pending';
//       }
//
//       // Attach file
//       final fileStream = http.ByteStream(selectedFile!.openRead());
//       final fileLength = await selectedFile!.length();
//       final multipartFile = http.MultipartFile('file', fileStream, fileLength,
//           filename: p.basename(selectedFile!.path),
//           contentType: _getMediaType(selectedFile!.path)
//       );
//       request.files.add(multipartFile);
//
//       // send
//       final streamedResp = await request.send();
//       final resp = await http.Response.fromStream(streamedResp);
//
//       setState(() { loading = false; });
//
//       if (resp.statusCode == 201 || resp.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded successfully")));
//         // go to home feed
//         if (!mounted) return;
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeFeed()));
//       } else {
//         final body = resp.body;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: ${resp.statusCode} - $body")));
//       }
//     } catch (e) {
//       setState(() { loading = false; });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload error: $e")));
//     }
//   }
//
//   MediaType _getMediaType(String pathStr) {
//     final ext = pathStr.toLowerCase();
//
//     if (ext.endsWith(".pdf")) return MediaType("application", "pdf");
//     if (ext.endsWith(".doc") || ext.endsWith(".docx")) {
//       return MediaType("application", "msword");
//     }
//     if (ext.endsWith(".png")) return MediaType("image", "png");
//     return MediaType("image", "jpeg");
//   }
//   @override
//   Widget build(BuildContext context) {
//     final subjectItems = topicsBySubject.keys.toList();
//
//     final topicItems = selectedSubject == null
//         ? <String>[]
//         : topicsBySubject[selectedSubject!] ?? <String>[];
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Community dropdown
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: DropdownButton<String>(
//                     value: selectedCommunity,
//                     hint: const Text("Select community", style: TextStyle(color: Colors.white70)),
//                     dropdownColor: Colors.grey[900],
//                     items: communities.map((c) {
//                       return DropdownMenuItem(value: c, child: Text(c));
//                     }).toList(),
//                     onChanged: (v) => setState(() => selectedCommunity = v),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Title
//                 TextField(
//                   controller: _titleController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Title',
//                     hintStyle: const TextStyle(color: Colors.white54),
//                     filled: true,
//                     fillColor: Colors.transparent,
//                     enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(6)),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // subject + topic inline
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedSubject,
//                         items: subjectItems.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
//                         onChanged: (v) {
//                           setState(() {
//                             selectedSubject = v;
//                             // reset topic when subject changes
//                             selectedTopic = null;
//                           });
//                         },
//                         dropdownColor: Colors.grey[900],
//                         decoration: const InputDecoration(
//                           labelText: "Subject",
//                           labelStyle: TextStyle(color: Colors.white70),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedTopic,
//                         items: topicItems.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
//                         onChanged: (v) => setState(() => selectedTopic = v),
//                         dropdownColor: Colors.grey[900],
//                         decoration: const InputDecoration(
//                           labelText: "Topic",
//                           labelStyle: TextStyle(color: Colors.white70),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // description
//                 TextField(
//                   controller: _descController,
//                   style: const TextStyle(color: Colors.white),
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     hintText: 'Description (optional)',
//                     hintStyle: const TextStyle(color: Colors.white54),
//                     enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(6)),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // file picker + preview
//                 GestureDetector(
//                   onTap: pickFile,
//                   child: Container(
//                     height: 150,
//                     width: double.infinity,
//                     decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
//                     child: selectedFile == null
//                         ? const Center(child: Text("Upload file (image/pdf/doc)", style: TextStyle(color: Colors.white70)))
//                         : Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Row(
//                         children: [
//                           Icon(_isImage(selectedFile!) ? Icons.image : Icons.picture_as_pdf, color: Colors.white70, size: 36),
//                           const SizedBox(width: 12),
//                           Expanded(child: Text(p.basename(selectedFile!.path), style: const TextStyle(color: Colors.white))),
//                           IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => setState(() => selectedFile = null))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: loading ? null : uploadNote,
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Continue", style: TextStyle(fontSize: 20)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Minimal MediaType helper to avoid external dependency
import 'dart:io';
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

  // Local subjects + topics mapping
  final Map<String, List<String>> topicsBySubject = {
    "DSA": ["Linked List", "Trees", "Recursion"],
    "OS": ["Paging", "Scheduling", "Concurrency"],
    "DBMS": ["ER Model", "Normalization"],
    "Maths": ["Calculus", "Linear Algebra"]
  };

  final List<String> communities = ["SDMCET", "Global", "Local College"];

  String? selectedCommunity;
  String? selectedSubject;
  String? selectedTopic;
  File? selectedFile;
  bool loading = false;

  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg', 'jpeg', 'png', // images
        'pdf', 'doc', 'docx'  // documents
      ],
    );
    if (res == null) return;
    final path = res.files.single.path;
    if (path == null) return;
    setState(() {
      selectedFile = File(path);
    });
  }

  bool _isImage(File f) {
    final ext = p.extension(f.path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
  }

  // Upload function — multipart
  Future<void> uploadNote() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a subject')));
      return;
    }
    if (selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a topic')));
      return;
    }
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a file to upload')));
      return;
    }

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('http://localhost:8080/notes/upload');
      final request = http.MultipartRequest('POST', uri);

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['subject'] = selectedSubject!;
      request.fields['topic'] = selectedTopic!;
      request.fields['subjects'] = selectedSubject!;
      request.fields['topics'] = selectedTopic!;
      request.fields['text'] = title;
      request.fields['description'] = _descController.text.trim();

      // Default moderation
      request.fields['moderation_status'] = 'approved';

      final fileStream = http.ByteStream(selectedFile!.openRead());
      final fileLength = await selectedFile!.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: p.basename(selectedFile!.path),
      );
      request.files.add(multipartFile);

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      setState(() => loading = false);

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uploaded successfully")),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFeed()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${resp.body}")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectItems = topicsBySubject.keys.toList();
    final topicItems =
    selectedSubject == null ? [] : topicsBySubject[selectedSubject!] ?? [];

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
              value: selectedCommunity,
              dropdownColor: Colors.grey[900],
              decoration: const InputDecoration(
                labelText: "Community",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              items: communities
                  .map((c) =>
                  DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCommunity = v),
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
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      labelText: "Subject",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    items: subjectItems
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedSubject = v;
                      selectedTopic = null;
                    }),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTopic,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      labelText: "Topic",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    items: topicItems
                        .map((t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(t),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedTopic = v),
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
              onTap: pickFile,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedFile == null
                    ? const Center(
                  child: Text("Upload file", style: TextStyle(color: Colors.white70)),
                )
                    : Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      _isImage(selectedFile!)
                          ? Icons.image
                          : Icons.picture_as_pdf,
                      color: Colors.white70,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.basename(selectedFile!.path),
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () =>
                          setState(() => selectedFile = null),
                    )
                  ],
                ),
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
}
