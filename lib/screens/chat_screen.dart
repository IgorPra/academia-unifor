import 'package:flutter/material.dart';
import 'package:academia_unifor/services/gemini_service.dart';
import 'package:academia_unifor/widgets/custom_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = "Bom dia!";
    } else if (hour < 18) {
      greeting = "Boa tarde!";
    } else {
      greeting = "Boa noite!";
    }

    setState(() {
      _messages.add({
        "sender": "Bot",
        "message": "$greeting Qual a sua dúvida relacionada a exercícios?",
      });
    });
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "Você", "message": userMessage});
        _isLoading = true;
      });

      _controller.clear();

      String reply = await _geminiService.getResponse(userMessage);

      setState(() {
        _messages.add({"sender": "Bot", "message": reply});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Perguntas sobre Treinos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  bool isUser = message["sender"] == "Você";
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? (isUser
                                    ? Colors.blueGrey[700]
                                    : Colors.grey[800])
                                : (isUser
                                    ? Colors.blue[200]
                                    : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${message['sender']}: ${message['message']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Digite sua pergunta...",
                      labelStyle: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.chat,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withAlpha(30)
                              : Colors.black.withAlpha(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),
                  CustomButton(
                    text: "Enviar",
                    icon: Icons.send,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
