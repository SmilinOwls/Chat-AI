import 'package:chat_ai_app/models/chat/chat.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
    required this.chats,
    required this.onChatSelected,
    required this.onChatDeleted,
  });

  final List<Chat> chats;
  final Function(Chat) onChatSelected;
  final Function(Chat) onChatDeleted;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            child: const ListTile(
              title: Text(
                'Chat AI',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.chats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Thread ${index + 1}'),
                  onTap: () {
                    widget.onChatSelected(widget.chats[index]);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.onChatDeleted(widget.chats[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
