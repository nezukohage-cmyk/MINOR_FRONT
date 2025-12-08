// homefeed.dart (updated)
// Replace your existing file with this.

import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';
import 'package:Reddit/quiz.dart';
import 'package:Reddit/pages/upload_note.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _currentIndex = 0;

  List<dynamic> feed = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  Future<void> loadFeed() async {
    setState(() => isLoading = true);
    try {
      final res = await Api().get("/feed/home");
      setState(() {
        feed = res["feed"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching feed: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _getPage() {
    if (_currentIndex == 0) return _buildFeedPage();
    if (_currentIndex == 1) return const QuizPage();
    if (_currentIndex == 2) return const UploadNotePage();
    if (_currentIndex == 3) return _placeholder("Inbox");
    if (_currentIndex == 4) return _placeholder("Profile");
    return _buildFeedPage();
  }

  Widget _placeholder(String text) {
    return Center(
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 22)),
    );
  }

  //
  // FEED PAGE
  //
  Widget _buildFeedPage() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _searchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadFeed,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : feed.isEmpty
          ? const Center(
        child: Text(
          "No notes available. Upload something!",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: feed.length,
        itemBuilder: (context, index) {
          final item = feed[index];
          if (item["type"] == "note") {
            return NoteCard(
                key: ValueKey(item["data"]?["id"] ?? index),
                data: Map<String, dynamic>.from(item["data"] ?? {}));
          }
          if (item["type"] == "question") {
            return QuestionCard(data: item["data"]);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white54),
          SizedBox(width: 8),
          Text("Search", style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (_currentIndex == 0) loadFeed();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "You"),
        ],
      ),
    );
  }
}

//
// NOTE CARD (single-image + actions)
//
class NoteCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const NoteCard({super.key, required this.data});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late int score;
  bool upvoted = false;
  bool downvoted = false;
  bool saved = false;
  bool isMember = true; // optimistic default

  @override
  void initState() {
    super.initState();
    // ensure numeric score
    score = (widget.data["score"] is int) ? widget.data["score"] as int : 0;

    // initial vote state: you can derive from arrays if backend provides them
    final upList = widget.data["upvotes"];
    final downList = widget.data["downvotes"];
    // if backend provides arrays of user ids you can set upvoted/downvoted here,
    // but without current user id we keep local defaults (user can toggle).
    // saved state from 'saved_by' could be read similarly if available.

    // membership: backend may pass 'is_member' boolean
    if (widget.data.containsKey("is_member")) {
      isMember = widget.data["is_member"] == true;
    }
  }

  Future<void> _upvote() async {
    final id = widget.data["id"];
    // optimistic UI
    setState(() {
      if (!upvoted) {
        score++;
        upvoted = true;
        downvoted = false;
      } else {
        // toggle off
        score--;
        upvoted = false;
      }
    });

    try {
      final res = await Api().post("/notes/$id/upvote");
      if (res != null && res is Map && res.containsKey("score")) {
        setState(() => score = (res["score"] as int?) ?? score);
      }
    } catch (e) {
      print("Upvote error: $e");
      // optionally revert on failure (kept simple here)
    }
  }

  Future<void> _downvote() async {
    final id = widget.data["id"];
    setState(() {
      if (!downvoted) {
        score--;
        downvoted = true;
        upvoted = false;
      } else {
        score++;
        downvoted = false;
      }
    });

    try {
      final res = await Api().post("/notes/$id/downvote");
      if (res != null && res is Map && res.containsKey("score")) {
        setState(() => score = (res["score"] as int?) ?? score);
      }
    } catch (e) {
      print("Downvote error: $e");
    }
  }

  Future<void> _saveNote() async {
    final id = widget.data["id"];
    setState(() => saved = !saved);
    try {
      await Api().post("/notes/$id/save");
    } catch (e) {
      print("Save error: $e");
    }
  }

  Future<void> _joinCommunity() async {
    // backend route assumed: POST /communities/:id/join
    final cid = widget.data["community_id"] ?? widget.data["communityId"];
    if (cid == null) {
      // no community id => just toggle locally
      setState(() => isMember = !isMember);
      return;
    }
    setState(() => isMember = true);
    try {
      await Api().post("/communities/$cid/join");
    } catch (e) {
      print("Join error: $e");
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      if (url.isEmpty) return;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Download/open error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    // Primary image determination:
    // Prefer single 'url' (your chosen single-file format). Fallback to first 'urls' if present.
    String? imageUrl;
    if (data.containsKey("url") && (data["url"] is String) && (data["url"] as String).trim().isNotEmpty) {
      imageUrl = data["url"] as String;
    } else {
      final dyn = data["urls"];
      if (dyn is List && dyn.isNotEmpty) {
        final candidate = dyn[0];
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          imageUrl = candidate.toString();
        }
      }
    }

    final createdAt =
        DateTime.tryParse(data["created_at"] ?? "") ?? DateTime.now();
    final timeAgo = timeAgoFormat(createdAt);

    // prefer 'community' or 'community_name'
    final communityName = (data["community"] ??
        data["community_name"] ??
        data["community_name"] ??
        "SDMCET")
        .toString();

    final noteId = data["id"] ?? data["_id"] ?? "";

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text("r/$communityName",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text("• $timeAgo", style: const TextStyle(color: Colors.white54)),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: isMember ? Colors.grey[800] : Colors.blueAccent,
                  ),
                  onPressed: isMember ? null : _joinCommunity,
                  child: Text(isMember ? "Joined" : "Join",
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // IMAGE PREVIEW
          GestureDetector(
            onTap: () {
              if (imageUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageView1(url: imageUrl!, postData: data),
                  ),
                );
              }
            },
            child: Container(
              height: 260,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[850],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                  ),
                ),
              )
                  : Container(
                color: Colors.grey[850],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),

          // ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _upvote,
                  icon: Icon(Icons.arrow_upward,
                      color: upvoted ? Colors.orange : Colors.white),
                ),

                // Score visible even if zero
                Text("$score", style: const TextStyle(color: Colors.white, fontSize: 16)),

                IconButton(
                  onPressed: _downvote,
                  icon: Icon(Icons.arrow_downward,
                      color: downvoted ? Colors.blue : Colors.white),
                ),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        isScrollControlled: true,
                        builder: (_) => CommentSheet(postId: noteId.toString()));
                  },
                  icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                ),
                const Spacer(),

                IconButton(
                  onPressed: _saveNote,
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                ),

                IconButton(
                  onPressed: () {
                    if (imageUrl != null) _downloadImage(imageUrl);
                  },
                  icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// FULLSCREEN VIEWER (single-image)
//
class FullscreenImageView1 extends StatelessWidget {
  final String url;
  final Map postData;

  const FullscreenImageView1({super.key, required this.url, required this.postData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.black,
              isScrollControlled: true,
              builder: (_) => CommentSheet(postId: postData["id"]));
        } else if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }
}

//
// QUESTION CARD
//
class QuestionCard extends StatelessWidget {
  final Map data;
  const QuestionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final text = data["text"] ?? "";
    final options = List<String>.from(data["options"] ?? []);

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            ...options.map(
                  (op) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(op, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// COMMENT SHEET
//
class CommentSheet extends StatelessWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: ListView(
          controller: controller,
          children: const [
            Text(
              "Comments coming soon...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

//
// TIME AGO FORMATTER
//
String timeAgoFormat(DateTime dt) {
  final diff = DateTime.now().difference(dt);

  if (diff.inMinutes < 1) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  if (diff.inDays < 7) return "${diff.inDays}d ago";
  return "${(diff.inDays / 7).floor()}w ago";
}
