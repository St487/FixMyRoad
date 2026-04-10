import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/chatbot_controller.dart';

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  bool _showSuggestions = true;
  final List<String> _allFaqs = [
    "How to report a road issue?",
    "How to track my report status?",
    "What categories of issues can I report?",
    "How long does it take for action?",
    "How to change my profile details?",
    "Is my report anonymous?",
    "How to upload a photo of the issue?",
    "Why my report is rejected?",
  ];

  List<String> _randomFaqs = [];
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Hello! I am your **FMR assistant**. How can I help you today?"
    }
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRandomFaqs();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
      _showSuggestions = false;
    });

    final response = await ChatbotController.sendMessage(
      message: text,
      userId: 1,
    );

    setState(() {
      _messages.add({
        "sender": "ai",
        "text": response["reply"] ?? "No response"
      });
      _isLoading = false;
    });
  }

  void _handleSend() {
    final text = _controller.text;
    _controller.clear();
    _sendMessage(text);
  }

  void _loadRandomFaqs() {
    setState(() {
      _allFaqs.shuffle();
      _randomFaqs = _allFaqs.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "FMR Support",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9B67BE), // Deepened the purple for better contrast
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildLoadingIndicator();
                }

                bool isUser = _messages[index]["sender"] == "user";
                return _buildChatBubble(_messages[index]["text"]!, isUser);
              },
            ),
          ),
          if (_showSuggestions) _buildSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE3D2F3) : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: isUser ? const Color(0xFF4A148C) : Colors.black87, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "Typing...",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Common Questions:", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: _randomFaqs.map((faq) {
              return ActionChip(
                label: Text(faq, style: const TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFFF8EFFF),
                side: const BorderSide(color: Color(0xFFD1B2E8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  _sendMessage(faq);
                  setState(() => _showSuggestions = false);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Ask about app or road issues...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF9B67BE),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}