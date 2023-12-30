import 'package:chat_ai_app/models/chat/chat.dart';
import 'package:chat_ai_app/screens/Chat_screen.dart';
import 'package:chat_ai_app/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Chat> chats = [];
  Chat? selectedChat;

  void _createNewChat() async {
    Chat newChat = Chat(
      createdAtTimeStamp: DateTime.now().millisecondsSinceEpoch,
      messages: [],
    );

    chats.add(newChat);
    _saveChats();

    setState(() {
      selectedChat = newChat;
    });
  }

  void _saveChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatsJson = jsonEncode(
      chats.map((chat) => chat.toJson()).toList(),
    );
    await prefs.setString('Chats', chatsJson);
  }

  void _loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatsJson = prefs.getString('Chats');

    if (chatsJson != null && chatsJson.isNotEmpty) {
      final chatsData = jsonDecode(chatsJson);

      if (chatsData is List) {
        chats = chatsData.map((data) => Chat.fromJson(data)).toList();
      } else if (chatsData is Map) {
        chats = [Chat.fromJson(chatsData)];
      }
    }

    setState(() {});
  }

  void _onChatSelected(Chat chat) {
    setState(() {
      selectedChat = chat;
    });
  }

  void _onChatDeleted(Chat chat) {
    setState(() {
      chats.remove(chat);
      selectedChat = null;
    });
    _saveChats();
  }

  void _onChatCleared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('Chats')){
      prefs.remove('Chats');
    }
    setState(() {
      chats.clear();
      selectedChat = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.8),
        title: Text('AI Chat App', style: Theme.of(context).textTheme.displayMedium),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        chats: chats,
        onChatSelected: _onChatSelected,
        onChatDeleted: _onChatDeleted,
      ),
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Create new chat'),
              onTap: _createNewChat,
            ),
            ListTile(
              title: const Text('Clear all chats'),
              onTap: _onChatCleared,
            )
          ],
        ),
      ),
      body: selectedChat != null
          ? ChatScreen(
              key: ValueKey(selectedChat?.createdAtTimeStamp),
              chat: selectedChat!,
            )
          : Container(
              alignment: Alignment.center,
              child: const Text('Select a chat thread to start messaging..'),
            ),
    );
  }
}
