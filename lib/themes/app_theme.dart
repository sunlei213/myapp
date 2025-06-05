import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true, // 推荐用于现代 Flutter 应用
      appBarTheme: const AppBarTheme( // 为 AppBar 设置统一主题
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ));
  }
}