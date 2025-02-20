import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final String geminiApiKey = 'API_KEY';

  @override
  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    String responseText = await fetchGeminiResponse(message.text, '');
    insertNewData(responseText);
  }

  Future<String> fetchGeminiResponse(String prompt, String context) async {
  final Uri url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey"
  );

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Com base nos seguintes dados do usuário:\n$context\n\nPergunta: $prompt"}
          ]
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    // Verifica se existem candidatos na resposta
    if (data.containsKey("candidates") && data["candidates"].isNotEmpty) {
      // Verifica se há conteúdo no primeiro candidato
      if (data["candidates"][0].containsKey("content") && data["candidates"][0]["content"].containsKey("parts")) {
        return data["candidates"][0]["content"]["parts"][0]["text"]; // Extraindo corretamente o texto da resposta
      }
    }
    return "Erro: Resposta inesperada da API"; // Caso os dados não estejam formatados corretamente
  } else {
    return "Erro na API: ${response.statusCode} - ${response.body}";
  }
}

  void insertNewData(String response) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: false,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Digite sua pergunta..."),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chat com Google Gemini API")),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}