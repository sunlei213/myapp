import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _backendAddressController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _accountInfoController = TextEditingController();

  static const String _backendAddressKey = 'backendAddress';
  static const String _apiKeyKey = 'apiKey';
  static const String _accountInfoKey = 'accountInfo';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _backendAddressController.dispose();
    _apiKeyController.dispose();
    _accountInfoController.dispose();
    super.dispose();
  }

  // 从 SharedPreferences 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _backendAddressController.text = prefs.getString(_backendAddressKey) ?? '';
      _apiKeyController.text = prefs.getString(_apiKeyKey) ?? '';
      _accountInfoController.text = prefs.getString(_accountInfoKey) ?? '';
    });
  }

  // 将设置保存到 SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendAddressKey, _backendAddressController.text);
    await prefs.setString(_apiKeyKey, _apiKeyController.text);
    await prefs.setString(_accountInfoKey, _accountInfoController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已成功保存！')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // 后端地址输入
            TextField(
              controller: _backendAddressController,
              decoration: const InputDecoration(
                labelText: '后端地址',
                hintText: '例如：https://api.example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16.0),

            // API 密钥输入
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API 密钥',
                hintText: '输入您的 API 密钥',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 隐藏敏感的 API 密钥输入
            ),
            const SizedBox(height: 16.0),

            // 账号信息输入
            TextField(
              controller: _accountInfoController,
              decoration: const InputDecoration(
                labelText: '账号信息',
                hintText: '例如：user@example.com 或 用户 ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24.0),

            // 保存按钮
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('保存设置'),
            ),
          ],
        ),
      ),
    );
  }
}