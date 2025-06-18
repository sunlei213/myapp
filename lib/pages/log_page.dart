import 'package:flutter/material.dart';
import 'package:myapp/api/stock_api.dart';
import 'package:myapp/main.dart';
import 'package:myapp/api/user_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late StockApi _stockApi;
  bool _isLoading = false; // 是否正在加载数据 (Whether data is being loaded)
  String? _error; // 错误信息 (Error message)
  final UserService _userService = getIt<UserService>();

  List<Map<String, String>> logList = [];

  @override
  void initState() {
    super.initState();
    _stockApi = _userService.currentApi; // 获取当前API实例 (Get current API instance)
    fetchLog();
  }

  Future<void> fetchLog() async {
    _isLoading = true;
    try {
      final log = await _stockApi.fetchLog();
      setState(() {
        _isLoading = false;
        _error = null;
        logList = log;
      });
    } catch (e) {
      setState(() {
        _error = '查询时发生错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 重新获取数据，确保显示最新状态
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志信息查询'),
        backgroundColor: Colors.teal, // AppBar 背景色 (AppBar background color)
        foregroundColor: Colors.white, // AppBar 前景色 (文字和图标颜色) (AppBar foreground color (text and icon color))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 子组件宽度撑满 (Stretch children's width)
          children: <Widget>[
            // 提交按钮 (Submit Button)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // 按钮背景色 (Button background color)
                foregroundColor: Colors.white, // 按钮文字颜色 (Button text color)
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : fetchLog, // 如果没有选择账户或正在加载，则禁用按钮 (Disable button if no account is selected or if loading)
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ), // 加载指示器 (Loading indicator)
                    )
                  : const Text('提交查询'),
            ),
            const SizedBox(height: 20),

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
            if (logList.isNotEmpty) // 如果账户详情不为空 (If account details are not null)
              Expanded(
                child: SingleChildScrollView(
                  // 使内容可滚动 (Make content scrollable)
                  child: Card(
                    elevation: 2, // 卡片阴影 (Card shadow)
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // 卡片圆角 (Card border radius)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '日志列表:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const Divider(), // 分割线 (Divider line)
                          //_buildStockTable(_accountDetails!.stocks),
                          _buildLogCard(logList),
                          const Divider(), // 分割线 (Divider line)
                          //_buildStockCard(_accountDetails!.stocks), // 股票卡片 (Stock card)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (!_isLoading && _error == null) // 如果没有加载且没有错误，显示提示信息 (If not loading and no error, show prompt)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    '暂无日志数据',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(List<Map<String, String>> logs) {
    if (logs.isEmpty) {
      return const Text('暂无日志数据');
    }
    return ListView.builder(
      shrinkWrap: true, // 根据内容调整高度
      physics: const NeverScrollableScrollPhysics(), // 禁用ListView自身的滚动
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final record = logs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text('账号：${record['userid']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('时间：${record['time']}  |  操作：${record['type']}'),
                Text('信息：${record['msg']}'),
              ],
            ),
            // isThreeLine: record.price > 0 && record.quantity > 0,
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              // 点击记录时导航到交易页面，并传递相关数据
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('消息: ${record['msg']}')),
              );
            },
          ),
        );
      },
    );
  }
}
