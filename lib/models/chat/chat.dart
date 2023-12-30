import 'package:chat_ai_app/models/chat/message.dart';

class Chat {
  final int createdAtTimeStamp;
  final List<Message> messages;

  Chat({required this.createdAtTimeStamp, required this.messages});

  factory Chat.fromJson(dynamic json) {
    List<Message> messages = [];

    if (json['messages'] is List) {
      List<dynamic> messagesData = json['messages'];
      messages = messagesData.map((data) => Message.fromJson(data)).toList();
    }

    return Chat(
      createdAtTimeStamp: json['createdAtTimeStamp'],
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'createdAtTimeStamp': createdAtTimeStamp,
    'messages': messages.map((message) => message.toJson()).toList(),
  };
}