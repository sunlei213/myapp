import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于日期格式化 (For date formatting)

// 模拟账户数据 (Simulated account data)
final List<Map<String, String>> _accounts = [
  {'id': 'account1', 'name': '账户一 (0012345678)'},
  {'id': 'account2', 'name': '账户二 (0087654321)'},
];

// 交易记录数据模型 (Transaction Record Data Model)
class TransactionRecord {
  final String id;
  final DateTime dateTime;
  final String type; // '买入', '卖出', '转入', '转出' (Buy, Sell, Transfer In, Transfer Out)
  final String stockName;
  final String stockCode;
  final double price;
  final int quantity;
  final double amount; // 总金额 (Total amount)

  TransactionRecord({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.stockName,
    required this.stockCode,
    required this.price,
    required this.quantity,
    required this.amount,
  });
}

// 模拟获取交易记录的函数 (Simulated function to fetch transaction records)
Future<List<TransactionRecord>> fetchTransactionHistory(
    String accountId, DateTime startDate, DateTime endDate) async {
  // 模拟网络延迟 (Simulate network delay)
  await Future.delayed(const Duration(seconds: 2));

  // 模拟基于日期过滤的数据 (Simulate data filtering based on date)
  List<TransactionRecord> allRecords = [
    TransactionRecord(id: 'TXN001', dateTime: DateTime(2024, 5, 1, 10, 30), type: '买入', stockName: '腾讯控股', stockCode: '00700', price: 350.50, quantity: 100, amount: 35050.00),
    TransactionRecord(id: 'TXN002', dateTime: DateTime(2024, 5, 3, 14, 15), type: '卖出', stockName: '阿里巴巴', stockCode: '09988', price: 85.20, quantity: 200, amount: 17040.00),
    TransactionRecord(id: 'TXN003', dateTime: DateTime(2024, 5, 5, 9, 45), type: '买入', stockName: '平安银行', stockCode: '000001', price: 12.80, quantity: 500, amount: 6400.00),
    TransactionRecord(id: 'TXN004', dateTime: DateTime(2024, 5, 10, 11, 00), type: '转入资金', stockName: '-', stockCode: '-', price: 0, quantity: 0, amount: 50000.00),
    TransactionRecord(id: 'TXN005', dateTime: DateTime(2024, 5, 12, 13, 20), type: '买入', stockName: '贵州茅台', stockCode: '600519', price: 1700.00, quantity: 10, amount: 17000.00),
    TransactionRecord(id: 'TXN006', dateTime: DateTime(2024, 5, 15, 10, 55), type: '卖出', stockName: '腾讯控股', stockCode: '00700', price: 355.00, quantity: 50, amount: 17750.00),
     TransactionRecord(id: 'TXN007', dateTime: DateTime(2023, 4, 1, 10, 30), type: '买入', stockName: '旧记录', stockCode: 'OLD01', price: 10.50, quantity: 100, amount: 1050.00),
  ];

  // 根据账户和日期范围筛选 (Filter by account and date range)
  // 实际应用中，这些筛选应该在后端完成 (In a real app, this filtering should be done on the backend)
  return allRecords.where((record) {
    // 简单模拟账户ID对交易记录的影响，实际可能更复杂
    // bool matchesAccount = accountId == 'account1' ? record.id.contains(RegExp(r'[13579]$')) : record.id.contains(RegExp(r'[02468]$'));
    // 为了演示，这里不严格按 accountId 过滤，仅演示日期过滤
    final recordDate = record.dateTime;
    return !recordDate.isBefore(startDate) && !recordDate.isAfter(endDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1))); // 包含结束日期当天
  }).toList();
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _selectedAccountId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30)); // 默认开始日期：30天前 (Default start date: 30 days ago)
  DateTime _endDate = DateTime.now(); // 默认结束日期：今天 (Default end date: today)

  List<TransactionRecord> _transactionRecords = [];
  bool _isLoading = false;
  String? _error;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd'); // 日期格式化工具 (Date formatter)

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
          if (_startDate.isAfter(_endDate)) { // 如果开始日期晚于结束日期，则将结束日期设为开始日期 (If start date is after end date, set end date to start date)
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) { // 如果结束日期早于开始日期，则将开始日期设为结束日期 (If end date is before start date, set start date to end date)
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
      final records = await fetchTransactionHistory(_selectedAccountId!, _startDate, _endDate);
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
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
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center,)))
            else if (_transactionRecords.isEmpty && _error == null)
               Expanded(child: Center(child: Text(_selectedAccountId == null ? '请选择账户并设置日期范围后点击查询。' :'请点击查询按钮以加载数据。', style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center)))
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
                        leading: CircleAvatar(
                          backgroundColor: record.type.contains('买入') || record.type.contains('转入') ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            record.type.contains('买入') ? Icons.add_shopping_cart :
                            record.type.contains('卖出') ? Icons.remove_shopping_cart :
                            record.type.contains('转入') ? Icons.arrow_downward : Icons.arrow_upward,
                            color: record.type.contains('买入') || record.type.contains('转入') ? Colors.green[700] : Colors.red[700],
                            size: 20,
                          ),
                        ),
                        title: Text('${record.stockName} (${record.stockCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('类型: ${record.type} | 时间: ${_dateFormatter.format(record.dateTime)} ${DateFormat.Hm().format(record.dateTime)}'),
                            if (record.price > 0 && record.quantity > 0)
                              Text('价格: ${record.price.toStringAsFixed(2)} | 数量: ${record.quantity}'),
                            Text('金额: ${record.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w500, color: record.type.contains('买入') || record.type.contains('转出') ? Colors.redAccent : Colors.green)),
                          ],
                        ),
                        isThreeLine: record.price > 0 && record.quantity > 0,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {
                          // 可以导航到交易详情页面 (Can navigate to transaction detail page)
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('点击了记录: ${record.id}')),
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