import 'package:flutter/material.dart';

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  final TextEditingController _controller = TextEditingController();
  
  // List to hold the chat history
  final List<Map<String, String>> _messages = [
  {"sender": "ai", "text": "Hello! I am your FMR assistant. How can I help you today?"},
  {"sender": "user", "text": "How do I report a pothole?"},
  {"sender": "ai", "text": "You can use the 'Add Report' card on your Home Page. Remember to upload at least one photo!"},
  {
      "sender": "user", 
      "text": "How do I see my nearby issues?"
    },
    {
      "sender": "ai", 
      "text": "On the Home Page, you will see a 'Nearby Reported Issues' preview. Tap 'Show All' to see the full list."
    },
];

  void _handleSend() {
    if (_controller.text.isEmpty) return;

    setState(() {
      // Add User Message
      _messages.add({"sender": "user", "text": _controller.text});
      
      // Simulate AI Response (Placeholder Text)
      _messages.add({
        "sender": "ai", 
        "text": "I am processing your question regarding: '${_controller.text}'. Please ensure your question is system-related."
      });
      
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Assistant"),
        backgroundColor: const Color.fromARGB(255, 207, 147, 237),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Chat History Area (Dynamic)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color.fromARGB(255, 192, 227, 234) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. Input Bar & 3. Send Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a system-related question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[400],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}