import 'package:flutter/material.dart';
import 'stock_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  late StockApi _currentApi; // 使用 late 关键字，因为在构造函数中初始化
  final List<Map<String, String>> _accounts = [];
  String _currentAccount = ''; // 假设默认选择第一个账户
  // 私有构造函数，防止直接实例化
  // 1. 保留私有构造函数，防止外部直接创建
  UserService._internal() {
    _currentApi = StockApi(baseUrl: '', apiKey: ''); // 初始数据
    _accounts.clear(); // 初始数据
    debugPrint('UserService 实例已创建');
  }

  // 2. 提供一个公共的工厂构造函数，供 GetIt 或其他外部代码调用
  //    这个工厂构造函数将调用私有构造函数来创建实例。
  factory UserService() {
    return UserService._internal();
  }
  // 暴露一个工厂构造函数或静态方法来获取实例
  // 在这里我们不直接暴露，而是通过 GetIt 注册
  // static final UserService _instance = UserService._internal();
  // static UserService get instance => _instance;

  StockApi get currentApi => _currentApi;
  String get currentAccount => _currentAccount;
  set currentAccount(String newAccount) {
    _currentAccount = newAccount; // 更新当前账户
    debugPrint('当前账户已更新为: $_currentAccount'); // 调试信息
    notifyListeners(); // 通知监听者更新
  }

  List<Map<String, String>> get accounts => _accounts;
  // 示例方法，用于更新账户列表
  void updateAccounts(List<Map<String, String>> newAccounts) {
    _accounts.clear(); // 清空现有数据
    _accounts.addAll(newAccounts); // 添加新数据
    if (_accounts.isNotEmpty && !_accounts.any((acc) => acc['id'] == _currentAccount)) {
      // 如果当前账户不存在新列表里，则默认选第一个
      _currentAccount = _accounts[0]['id'] ?? '';
    } else if (_accounts.isEmpty) {
      _currentAccount = ''; // 如果账户列表为空，当前账户也清空
    }
    debugPrint('账户列表已更新: $_accounts');
    notifyListeners(); // 通知监听者更新
  }

  set accounts(List<Map<String, String>> newAccounts) {
    _accounts.clear(); // 清空现有数据
    _accounts.addAll(newAccounts); // 添加新数据
    if (_accounts.isNotEmpty && !_accounts.any((acc) => acc['id'] == _currentAccount)) {
      // 如果当前账户不存在新列表里，则默认选第一个
      _currentAccount = _accounts[0]['id'] ?? '';
    } else if (_accounts.isEmpty) {
      _currentAccount = ''; // 如果账户列表为空，当前账户也清空
    }
    debugPrint('账户列表已更新: $_accounts');
    notifyListeners(); // 通知监听者更新
  }

  // 从 SharedPreferences 加载设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('backendAddress') ?? ''; // 从 SharedPreferences 加载 baseUrl
    final apiKey = prefs.getString('apiKey') ?? '123456'; // 从 SharedPreferences 加载 apiKey
    updateApiConfig(baseUrl, apiKey); // 更新当前 API 配置
    // 加载账户列表
    // 只有当 baseUrl 不为空时才尝试从服务器获取选项
    if (baseUrl.isNotEmpty) {
      try {
        debugPrint('Attempting to fetch options from: $baseUrl/form/options');
        final accountList = await _currentApi.fetchOption(); // 从服务器加载账户列表
        updateAccounts(accountList); // 更新当前账户列表
      } catch (e) {
        debugPrint('Error fetching options during loadSettings: $e');
        // 如果获取失败，清空账户列表并重置当前账户，防止使用无效数据
        _accounts.clear();
        _currentAccount = '';
        notifyListeners(); // 通知UI，加载失败，账户列表为空
        // 你可能还希望通过某种方式向用户显示此错误，例如使用 Snackbar
      }
    } else {
      debugPrint('Base URL is empty. Skipping fetchOption during loadSettings.');
      // 如果 baseUrl 为空，确保账户列表也是空的
      _accounts.clear();
      _currentAccount = '';
      notifyListeners(); // 通知UI，加载失败，账户列表为空
    }
    debugPrint('API 配置已加载: $baseUrl, $apiKey'); // 调试信息
  }

  // 示例方法，用于更新当前 API 配置
  void updateApiConfig(String baseUrl, String apiKey) {
    _currentApi.baseUrl = baseUrl; // 更新 API 地址;
    _currentApi.apiKey = apiKey; // 更新 API 密钥;
    debugPrint('API 配置已更新: $baseUrl, $apiKey');
  }

  void updateApiUrl(String url) {
    _currentApi.baseUrl = url; // 更新 API 地址;
    debugPrint('API 地址已更新为: $url');
  }

  void updateApiKey(String newKey) {
    _currentApi.apiKey = newKey; // 更新 API 密钥;
    debugPrint('API 密钥已更新为: $newKey');
  }
}
