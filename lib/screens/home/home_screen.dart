import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_data.dart';
import '../chat/chat_list_screen.dart';
import '../moments/moments_screen.dart';
import '../contacts/contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatListScreen(),
    MomentsScreen(),
    ContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AppData>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
            onPressed: () => context.read<AppData>().logout(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat), label: '聊天'),
          NavigationDestination(icon: Icon(Icons.photo_library), label: '朋友圈'),
          NavigationDestination(icon: Icon(Icons.contact_page), label: '联系方式'),
        ],
      ),
    );
  }
}
