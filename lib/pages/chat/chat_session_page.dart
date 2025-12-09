// lib/pages/chat/chat_session_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class ChatSessionPage extends StatefulWidget {
  final String sessionId;
  const ChatSessionPage({super.key, required this.sessionId});

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  List<dynamic> messages = [];
  bool loading = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadSession();
    // optional polling - every 5 seconds to update assistant reply if it takes time:
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => loadSession(silent: true));
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> loadSession({bool silent = false}) async {
    if (!silent) setState(() => loading = true);
    try {
      final res = await Api().get("/chat/session/${widget.sessionId}");
      final data = res["data"] ?? res["session"] ?? res;
      if (data is Map && data["messages"] is List) {
        messages = List.from(data["messages"]);
      } else if (res["messages"] is List) {
        messages = List.from(res["messages"]);
      } else {
        messages = [];
      }
      // scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load chat: $e")));
      }
    } finally {
      if (!silent) setState(() => loading = false);
    }
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // optimistically add user's message to UI
      messages.add({"role": "user", "text": text});
      _controller.clear();
    });
    _scrollToBottom();

    try {
      // POST to send message and receive assistant reply
      final res = await Api().postJson("/chat/session/${widget.sessionId}/send", body: {
        "message": text,
      });

      // Backend may return object with updated session or assistant reply under data
      // We reload session to get stored messages (most robust)
      await loadSession();
    } catch (e) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Send failed: $e")));
      // optionally remove last optimistic message or mark failed
    }
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget bubble(Map msg) {
    final role = (msg["role"] ?? "assistant").toString();
    final text = (msg["text"] ?? "").toString();

    final isUser = role.toLowerCase() == "user";
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Colors.blueAccent : Colors.grey[800];
    final textColor = Colors.white;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: isUser ? 12 : 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isUser ? 14 : 2),
              bottomRight: Radius.circular(isUser ? 2 : 14),
            ),
          ),
          child: Text(text, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: Colors.grey[900],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // on mobile, pop back to list
                    if (!isWide) Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Text("Chat", style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i] as Map;
                return bubble(msg);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    minLines: 1,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
