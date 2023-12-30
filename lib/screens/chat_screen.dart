import 'package:chat_ai_app/models/chat/chat.dart';
import 'package:chat_ai_app/models/chat/message.dart';
import 'package:chat_ai_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [...widget.chat.messages];
    _loadMessages();
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson =
        prefs.getString('messages_${widget.chat.createdAtTimeStamp}');

    if (messagesJson != null && messagesJson.isNotEmpty) {
      List<dynamic> messagesData = jsonDecode(messagesJson);
      setState(() {
        messages = messagesData.map((data) => Message.fromJson(data)).toList();
      });
    }
  }

  void _saveChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(
      widget.chat.toJson(),
    );
    await prefs.setString('Chats', conversationsJson);

    String messagesJson =
        jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString(
        'messages_${widget.chat.createdAtTimeStamp}', messagesJson);
  }

  void _sendMessageToAI(String message) async {
    Message userMessage = Message(text: message, isUser: true);

    setState(() {
      widget.chat.messages.add(userMessage);
      messages = List.from(widget.chat.messages);
    });

    ChatService chatService = ChatService();
    chatService.askAI(
      messages: messages,
      onSuccess: (String response) {
        _saveChats();

        setState(() {
          widget.chat.messages.add(Message(text: response, isUser: false));
          messages = List.from(widget.chat.messages);
        });

        _messageController.clear();
      },
      onError: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(
                    message.text,
                    textAlign:
                        message.isUser ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: message.isUser ? Colors.blue : Colors.black,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: message.isUser ? 20.0 : 8.0,
                  ),
                  trailing: message.isUser
                      ? Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/man.png'),
                            ),
                          ),
                        )
                      : null,
                  leading: message.isUser
                      ? null
                      : Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/chat_ai.png'),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message ChatAI...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _messageController.text.isNotEmpty
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _messageController.text.isEmpty
                        ? null
                        : () {
                            _sendMessageToAI(_messageController.text);
                          },
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
