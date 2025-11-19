import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class MessageBoardList extends StatelessWidget {
  final List<Map<String, dynamic>> boards;

  const MessageBoardList({super.key, required this.boards});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                board['icon'] ?? '💬',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              board['name'] ?? 'Unknown Board',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Tap to view messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    boardId: board['id'],
                    boardName: board['name'],
                    boardIcon: board['icon'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

