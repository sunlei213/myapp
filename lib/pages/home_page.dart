import 'package:flutter/material.dart';
import 'package:myapp/api/stock_api.dart';
import 'package:myapp/models/account.dart';
import 'package:myapp/models/stock_info.dart';
import 'package:myapp/main.dart';
import 'package:myapp/api/user_service.dart';
import 'package:myapp/pages/trade_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedAccountId; // 当前选择的账户ID (Currently selected account ID)
  Account? _accountDetails; // 获取到的账户详情 (Fetched account details)
  bool _isLoading = false; // 是否正在加载数据 (Whether data is being loaded)
  String? _error; // 错误信息 (Error message)
  final UserService _userService = getIt<UserService>();
  late StockApi _stockApi; // 股票API实例 (Stock API instance)
  final List<Map<String, String>> _accounts = []; // 账户列表 (Account list)

  @override
  void initState() {
    super.initState();
    _stockApi = _userService.currentApi; // 获取当前API实例 (Get current API instance)
    _onUserServiceChange();
    // 监听 UserService 的变化
    _userService.addListener(_onUserServiceChange);
  }

  @override
  void dispose() {
    _userService.removeListener(_onUserServiceChange);
    super.dispose();
  }

  // UserService 变化时的回调 (Callback when UserService changes)
  void _onUserServiceChange() {
    // 当 UserService 中的数据发生变化时，更新UI
    setState(() {
      _accounts.clear(); // 初始数据 (Initial data)
      _accounts.addAll(_userService.accounts); // 初始数据 (Initial data)
      _selectedAccountId = _userService.currentAccount; // 初始数据 (Initial data)
    });
  }

  // 查询账户数据的方法 (Method to query account data)
  Future<void> _queryAccountData() async {
    if (_selectedAccountId == null) {
      setState(() {
        _error = '请先选择一个账户';
        _accountDetails = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _accountDetails = null; // 清除之前的详情 (Clear previous details)
    });
    debugPrint(_selectedAccountId);

    try {
      final data = await _stockApi.fetchAccountInfo(_selectedAccountId!);
      setState(() {
        _accountDetails = data;
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
        title: const Text('账户信息查询'),
        backgroundColor: Colors.teal, // AppBar 背景色 (AppBar background color)
        foregroundColor: Colors.white, // AppBar 前景色 (文字和图标颜色) (AppBar foreground color (text and icon color))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 子组件宽度撑满 (Stretch children's width)
          children: <Widget>[
            // 账户选择 (Account Selection)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '选择账户',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.teal.withOpacity(0.1),
              ),
              value: _selectedAccountId,
              hint: const Text('请选择一个账户'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAccountId = newValue;
                  _accountDetails = null; // 账户更改时重置详情 (Reset details when account changes)
                  _error = null;
                });
              },
              items: _accounts.map<DropdownMenuItem<String>>((
                Map<String, String> account,
              ) {
                return DropdownMenuItem<String>(
                  value: account['id'],
                  child: Text(account['name']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

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
              onPressed: _selectedAccountId == null || _isLoading
                  ? null
                  : _queryAccountData, // 如果没有选择账户或正在加载，则禁用按钮 (Disable button if no account is selected or if loading)
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

            if (_accountDetails != null) // 如果账户详情不为空 (If account details are not null)
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
                          _buildInfoRow('姓名:', _accountDetails!.name),
                          _buildInfoRow(
                            '可用余额（元）:',
                            '¥${_accountDetails!.usedmoney.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            '持仓市值（元）:',
                            '¥${_accountDetails!.stocksvalue.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            '总资产（元）:',
                            '¥${_accountDetails!.totlemoney.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            '股票列表:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const Divider(), // 分割线 (Divider line)
                          _buildStockTable(_accountDetails!.stocks),
                          const Divider(), // 分割线 (Divider line)
                          _buildStockCard(_accountDetails!.stocks), // 股票卡片 (Stock card)
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
                    '选择账户并点击“提交查询”以显示数据。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建信息行的辅助方法 (Helper method to build info rows)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // 构建股票表格的辅助方法 (Helper method to build stock table)
  Widget _buildStockTable(List<StockInfo> stocks) {
    if (stocks.isEmpty) {
      return const Text('暂无股票数据');
    }
    return SingleChildScrollView(
      // 添加横向滚动以便表格过宽时可以滚动 (Added for horizontal scrolling if table is too wide)
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12.0, // 列间距 (Column spacing)
        headingRowColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          return Colors.teal.withOpacity(
            0.2,
          ); // 表头背景色 (Header row background color)
        }),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ), // 表头文字样式 (Header text style)
        columns: const [
          DataColumn(label: Text('证券代码')),
          DataColumn(label: Text('证券名称')),
          DataColumn(label: Text('参考持股')),
          DataColumn(label: Text('可用股份')),
          DataColumn(label: Text('成本价')),
          DataColumn(label: Text('当前价')),
          DataColumn(label: Text('浮动盈亏')),
        ],
        rows: stocks.map((stock) {
          return DataRow(
            cells: [
              DataCell(Text(stock.code)),
              DataCell(Text(stock.name)),
              DataCell(Text(stock.holdings.toString())),
              DataCell(Text(stock.available.toString())),
              DataCell(Text(stock.costPrice.toStringAsFixed(2))),
              DataCell(Text(stock.currentPrice.toStringAsFixed(2))),
              DataCell(
                Text(
                  stock.profitLoss.toStringAsFixed(2),
                  style: TextStyle(
                    color: stock.profitLoss >= 0
                        ? Colors.green
                        : Colors.red, // 根据盈亏显示不同颜色 (Display different colors based on profit/loss)
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockCard(List<StockInfo> stocks) {
    if (stocks.isEmpty) {
      return const Text('暂无股票数据');
    }
    return ListView.builder(
      shrinkWrap: true, // 根据内容调整高度
      physics: const NeverScrollableScrollPhysics(), // 禁用ListView自身的滚动
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final record = stocks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text('${record.name} (${record.code})', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('参考持股: ${record.holdings.toString()} | 可用股份: ${record.available.toString()}'),
                Text('成本价: ${record.costPrice.toStringAsFixed(3)} | 当前价: ${record.currentPrice.toStringAsFixed(3)}'),
                Text('浮动盈亏: ${record.profitLoss.toStringAsFixed(2)} | 浮动盈亏(%): ${record.lossPercent.toStringAsFixed(3)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: record.profitLoss >= 0 ? Colors.redAccent : Colors.green)),
                Text('冻结持股: ${record.lockedamount.toString()} | 在途股份: ${record.buyamount.toString()}'),
              ],
            ),
            // isThreeLine: record.price > 0 && record.quantity > 0,
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              // 点击记录时导航到交易页面，并传递相关数据
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TradePage(
                    initialStockCode: record.code, // 股票代码
                    initialQuantity: record.available.toString(), // 可用股份
                    initialPrice: record.currentPrice.toStringAsFixed(3), // 当前价格 (格式化为2位小数)
                    initialAccountId: _selectedAccountId, // 当前选择的账户ID
                    initialAction: TradeAction.sell, // 默认设置为“卖出”操作
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
