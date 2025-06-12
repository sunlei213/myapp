import 'package:flutter/material.dart';
import 'package:myapp/api/user_service.dart';
import 'package:myapp/main.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/trade_page.dart';
import 'package:myapp/pages/history_page.dart';
import 'package:myapp/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final UserService _userService = getIt<UserService>();

  final List<Widget> _pages = [
    const HomePage(),
    const TradePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadSettings() async {
    await _userService.loadSettings(); // 确保加载设置完成
    setState(() {}); // 刷新界面
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // You can customize the color
        unselectedItemColor: Colors.grey, // You can customize the color
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Use this if you have more than 3 items
      ),
    );
  }
}
