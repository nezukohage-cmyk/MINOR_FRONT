import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';
import 'package:Reddit/quiz.dart';
import 'package:Reddit/pages/upload_note.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
          ? const Center(
          child: CircularProgressIndicator(color: Colors.white))
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
            return NoteCard(data: item["data"]);
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
          Text("Search",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
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
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "You"),
        ],
      ),
    );
  }
}

//
// NOTE CARD (Reddit Style)
//
class NoteCard extends StatelessWidget {
  final Map data;
  const NoteCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final url = data["url"] ?? "";
    final fileType = data["file_type"] ?? "";
    final fileName = data["file_name"] ?? "";
    final createdAt = DateTime.tryParse(data["created_at"] ?? "") ?? DateTime.now();

    final timeAgo = timeAgoFormat(createdAt);
    final community = data["community"] ?? "UnknownCommunity";

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
                Text("r/$community",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text("• $timeAgo",
                    style: const TextStyle(color: Colors.white54)),
                const Spacer(),
                JoinButton(community: community),
              ],
            ),
          ),

          // IMAGE PREVIEW
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          FullscreenImageView(url: url, postData: data)));
            },
            child: Container(
              height: 260,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          ),

          // ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_upward, color: Colors.white)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_downward, color: Colors.white)),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          isScrollControlled: true,
                          builder: (_) => CommentSheet(postId: data["id"]));
                    },
                    icon: const Icon(Icons.mode_comment_outlined,
                        color: Colors.white)),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border,
                        color: Colors.white)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_for_offline_outlined,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
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
// FULLSCREEN VIEWER
//
class FullscreenImageView extends StatelessWidget {
  final String url;
  final Map postData;

  const FullscreenImageView({super.key, required this.url, required this.postData});

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
// JOIN BUTTON (Fake for now)
//
class JoinButton extends StatelessWidget {
  final String community;

  const JoinButton({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    bool isJoined = false;

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isJoined ? Colors.grey[800] : Colors.blueAccent,
      ),
      onPressed: () {},
      child: Text(
        isJoined ? "Joined" : "Join",
        style: const TextStyle(color: Colors.white),
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