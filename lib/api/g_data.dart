import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 这是我们的数据模型，它扩展了 ChangeNotifier
// 当数据发生变化时，调用 notifyListeners() 会通知所有监听者

class Mydata with ChangeNotifier {
  String _url = '';
  String _apiKey = '';
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2797368052.

  List<String> _accountList = [];

  static const String _backendAddressKey = 'backendAddress';
  static const String _apiKeyKey = 'apiKey';
  static const String _accountInfoKey = 'accountList';


  String get apiKey => _apiKey;
  List<String> get accountList => _accountList;
  String get url => _url;
  // SharedPreferences 实例，用于读写数据
  late SharedPreferences _prefs;

  // 构造函数现在是异步的，因为它需要初始化 SharedPreferences
  Mydata() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // 尝试从 SharedPreferences 中获取保存的值，如果没有则默认为 0
    _url = _prefs.getString(_backendAddressKey) ?? '';
    _apiKey = _prefs.getString(_apiKeyKey) ?? '';
    _accountList = _prefs.getStringList(_accountInfoKey) ?? [];
    notifyListeners(); // 通知 UI 初始值已加载
  }

  void increment() {

    notifyListeners(); // 通知所有监听此 ChangeNotifier 的 widget 重新构建
  }
}