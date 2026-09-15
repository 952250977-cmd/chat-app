import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_data.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final currentUid = appData.currentUser!.uid;
    final otherUsers = appData.users.where((u) => u.uid != currentUid).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '模拟用户列表（演示数据）',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: otherUsers.isEmpty
              ? const Center(child: Text('暂无其他用户'))
              : ListView.builder(
                  itemCount: otherUsers.length,
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    final messages = appData.getMessages(user.uid);
                    final lastMsg = messages.isNotEmpty ? messages.last.content : '';
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.displayName[0].toUpperCase()),
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(otherUser: user)),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
