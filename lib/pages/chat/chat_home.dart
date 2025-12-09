import 'package:flutter/material.dart';
import 'package:Reddit/services/api.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scroll = ScrollController();

  List<Map<String, String>> messages = [];
  bool sending = false;

  // Scroll to bottom after new message
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      sending = true;
    });

    controller.clear();
    scrollToBottom();

    try {
      final res = await Api().postJson(
        "/chat/ask",
        body: {
          "subject": "",
          "question": text,
        },
      );

      final botReply = res["answer"] ?? "Error: No response";

      setState(() {
        messages.add({"role": "assistant", "text": botReply});
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "text": "⚠️ Error contacting chatbot: $e"
        });
      });
    }

    setState(() => sending = false);
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Chatbot", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blueGrey[800]
                          : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      msg["text"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),


          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: const Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: sending
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: sending ? null : sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
