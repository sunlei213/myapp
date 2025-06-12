import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/main.dart';
import 'package:myapp/api/user_service.dart';
import 'package:myapp/api/stock_api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _backendAddressController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final UserService _userService = getIt<UserService>();
  String? _backendAddress; // 后端地址 (Backend address);)
  String? _error; // 错误信息 (Error message)

  static const String _backendAddressKey = 'backendAddress';
  static const String _apiKeyKey = 'apiKey';
  static const String _accountNo = 'accountNo';
  static const String _accountName = 'accountName';
  static const String _accountId = 'accountId';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _backendAddressController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  // 从 SharedPreferences 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _backendAddressController.text = prefs.getString(_backendAddressKey) ?? '';
      _apiKeyController.text = prefs.getString(_apiKeyKey) ?? '';
      _backendAddress = _backendAddressController.text;
    });
  }

  // 将设置保存到 SharedPreferences
  Future<void> _saveSettings() async {
    if (_backendAddress == '') {
      setState(() {
        _error = '请先设置后端地址';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendAddressKey, _backendAddressController.text);
    await prefs.setString(_apiKeyKey, _apiKeyController.text);

    final StockApi stockapi = _userService.currentApi;
    try {
      stockapi.baseUrl = _backendAddressController.text; // 更新后端地址 (Update backend address)

      stockapi.apiKey = _apiKeyController.text; // 更新 API 密钥 (Update API key)

      final data = await stockapi.fetchOption(); // 测试连接 (Test connection)
      await prefs.setInt(_accountNo, data.length); // 保存账户数量 (Save account number)
      final List<String> accountIdList = []; // 账户ID列表 (Account ID list)
      final List<String> accountNameList = []; // 账户名称列表 (Account name list)
      for (Map<String, String> account in data) {
        accountIdList.add(account['id']!); // 添加账户ID (Add account ID)
        accountNameList.add(account['name']!); // 添加账户名称 (Add account name)
      }
      await prefs.setStringList(_accountName, accountNameList); // 保存账户名称 (Save account name)
      await prefs.setStringList(_accountId, accountIdList); // 保存账户ID (Save account ID)
      _userService.currentAccount = accountIdList[0]; // 假设默认选择第一个账户 (Assume default select first account)
      _userService.accounts = data; // 更新账户列表 (Update account list)
    } catch (e) {
      setState(() {
        _error = '连接失败: $e'; // 显示错误信息 (Display error message)
      });
      return; // 不保存设置 (Don't save settings if connection fails)
    }
    setState(() {
      _error = null; // 清除错误信息 (Clear error message)
    });

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
                onChanged: (value) {
                  setState(() {
                    _backendAddress = value; // 更新后端地址 (Update backend address)
                  });
                }),
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

            // 保存按钮
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('保存设置'),
            ),

            // 显示区域 (Display Area)
            if (_error != null) // 如果有错误信息 (If there is an error message)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
