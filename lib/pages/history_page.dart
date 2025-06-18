import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于日期格式化 (For date formatting)
import 'package:myapp/api/stock_api.dart';
import 'package:myapp/api/user_service.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/trade_record.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late StockApi _stockApi; // 股票API实例 (Stock API instance)
  final UserService _userService = getIt<UserService>();
  String? _selectedAccountId;
  DateTime _startDate =
      DateTime.now().subtract(const Duration(days: 30)); // 默认开始日期：30天前 (Default start date: 30 days ago)
  DateTime _endDate = DateTime.now(); // 默认结束日期：今天 (Default end date: today)
  final List<Map<String, String>> _accounts = []; // 账户列表 (Account list)

  List<TradeRecord> _transactionRecords = [];
  bool _isLoading = false;
  String? _error;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd'); // 日期格式化工具 (Date formatter)

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

  Future<List<TradeRecord>> fetchTradeRecordHistory(String accountId, DateTime startDate, DateTime endDate) async {
    // 根据账户和日期范围筛选 (Filter by account and date range)
    // 实际应用中，这些筛选应该在后端完成 (In a real app, this filtering should be done on the backend)
    final DateFormat dateFormatter = DateFormat('yyyyMMdd'); // 日期格式化工具 (Date formatter)
    var startdate = dateFormatter.format(startDate);
    var enddate = dateFormatter.format(endDate);
    List<TradeRecord> records =
        await _stockApi.fetchTradeHistory(accountId: accountId, startDate: startdate, endDate: enddate);
    return records;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000), // 可选的最早日期 (Earliest selectable date)
      lastDate: DateTime.now().add(const Duration(days: 365)), // 可选的最晚日期 (Latest selectable date)
      helpText: isStartDate ? '选择开始日期' : '选择结束日期',
      cancelText: '取消',
      confirmText: '确认',
      locale: const Locale('zh'), // 设置为中文 (Set to Chinese)
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            // 如果开始日期晚于结束日期，则将结束日期设为开始日期 (If start date is after end date, set end date to start date)
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            // 如果结束日期早于开始日期，则将开始日期设为结束日期 (If end date is before start date, set start date to end date)
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _queryHistory() async {
    if (_selectedAccountId == null) {
      setState(() {
        _error = '请先选择一个账户';
        _transactionRecords = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _transactionRecords = []; // 清空旧数据 (Clear old data)
    });

    try {
      final records = await fetchTradeRecordHistory(_selectedAccountId!, _startDate, _endDate);
      setState(() {
        _transactionRecords = records;
        if (records.isEmpty) {
          _error = '在选定日期范围内没有找到交易记录。';
        }
      });
    } catch (e) {
      setState(() {
        _error = '查询历史记录时发生错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易记录查询'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 查询条件区域 (Query Criteria Area)
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. 选择账户 (Account Selection)
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('选择账户'),
                      value: _selectedAccountId,
                      hint: const Text('请选择查询账户'),
                      items: _accounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account['id'],
                          child: Text(account['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      },
                      validator: (value) => value == null ? '请选择一个账户' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. 日期选择 (Date Selection)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: _inputDecoration('开始日期'),
                              child: Text(_dateFormatter.format(_startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text("至", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: _inputDecoration('结束日期'),
                              child: Text(_dateFormatter.format(_endDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. 查询按钮 (Query Button)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('查询'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: _isLoading || _selectedAccountId == null ? null : _queryHistory,
                    ),
                  ],
                ),
              ),
            ),

            // 结果显示区域 (Results Display Area)
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _transactionRecords.isEmpty)
              Expanded(
                  child: Center(
                      child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )))
            else if (_transactionRecords.isEmpty && _error == null)
              Expanded(
                  child: Center(
                      child: Text(_selectedAccountId == null ? '请选择账户并设置日期范围后点击查询。' : '请点击查询按钮以加载数据。',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _transactionRecords.length,
                  itemBuilder: (context, index) {
                    final record = _transactionRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: Icon(
                          record.type.contains('买入') ? Icons.add_shopping_cart : Icons.remove_shopping_cart,
                          color: record.type.contains('买入') ? Colors.red[700] : Colors.green[700],
                          size: 20,
                          //  ),
                        ),
                        title: Text('${record.name} (${record.code}) | 市场：${record.market}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('时间: ${record.date} ${record.time}'),
                            Text('类型: ${record.type} | 状态: ${record.status}'),
                            Text('委托价格: ${record.price.toStringAsFixed(3)} | 委托数量: ${record.volume}'),
                            if (record.price1 > 0 && record.volume1 > 0)
                              Text('成交价格: ${record.price1.toStringAsFixed(3)} | 成交数量: ${record.volume1}'),
                            if (record.returnVol > 0) Text('撤单数量: ${record.returnVol}'),
                            Text('成交金额: ${(record.price1 * record.volume1).toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: record.type.contains('买入') ? Colors.redAccent : Colors.green)),
                          ],
                        ),
                        //isThreeLine: record.price1 > 0 && record.volume1 > 0,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                        onTap: () {
                          // 可以导航到交易详情页面 (Can navigate to transaction detail page)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('消息: ${record.msg}')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.blueGrey.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}
