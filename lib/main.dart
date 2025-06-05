import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'pages/main_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Stock App',
      theme: AppTheme.lightTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
      },
      // 支持中文日期选择器 (Support for Chinese date picker)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文简体 (Chinese Simplified)
        Locale('en', 'US'), // English
      ],
      locale: const Locale('zh'), // 默认设置为中文 (Default to Chinese)
      debugShowCheckedModeBanner: false, // 移除调试横幅
    );
  }
}
/*
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page - Account Information')),
    );
  }
}

class TradePage extends StatelessWidget {
  const TradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade')),
      body: const Center(child: Text('Trade Page - Order Placement')),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade History')),
      body: const Center(child: Text('Trade History Page - Record Query')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page - Backend Address and API Key'),
      ),
    );
  }
}
*/