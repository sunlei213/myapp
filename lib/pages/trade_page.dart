import 'package:flutter/material.dart';

// 定义委托操作类型 (Define order action types)
enum TradeAction { buy, sell, cancel, query }

// 模拟市场数据 (Simulated market data)
final List<Map<String, String>> _markets = [
  {'id': 'sh', 'name': '上海 (Shanghai)'},
  {'id': 'sz', 'name': '深圳 (Shenzhen)'},
];

// 模拟账户数据 (Simulated account data)
final List<Map<String, String>> _accounts = [
  {'id': 'account1', 'name': '账户一 (0012345678)'},
  {'id': 'account2', 'name': '账户二 (0087654321)'},
];

class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final _formKey = GlobalKey<FormState>(); // 用于表单验证 (For form validation)

  String? _selectedAccountId; // 选择的账户ID (Selected account ID)
  String? _selectedMarketId; // 选择的市场ID (Selected market ID)
  TradeAction _selectedAction = TradeAction.buy; // 默认选择买入 (Default to Buy)

  // TextEditingControllers 用于获取输入框的值 (TextEditingControllers to get input values)
  final TextEditingController _stockCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isLoading = false; // 处理提交状态 (Handle submission state)

  @override
  void dispose() {
    // 清理 controllers (Clean up controllers)
    _stockCodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitTrade() async {
    if (_formKey.currentState!.validate()) { // 触发表单验证 (Trigger form validation)
      _formKey.currentState!.save(); // 保存表单数据 (Save form data)

      setState(() {
        _isLoading = true;
      });

      // --- 模拟网络请求或处理 ---
      await Future.delayed(const Duration(seconds: 1));
      // --- 模拟结束 ---

      setState(() {
        _isLoading = false;
      });

      // 构建提交信息 (Construct submission information)
      String actionText = '';
      switch (_selectedAction) {
        case TradeAction.buy:
          actionText = '买入';
          break;
        case TradeAction.sell:
          actionText = '卖出';
          break;
        case TradeAction.cancel:
          actionText = '撤单';
          break;
        case TradeAction.query:
          actionText = '查询委托';
          break;
      }

      String message = '账户: ${_accounts.firstWhere((acc) => acc['id'] == _selectedAccountId)['name']}\n'
                       '操作: $actionText\n';

      if (_selectedAction == TradeAction.buy || _selectedAction == TradeAction.sell) {
        message += '市场: ${_markets.firstWhere((m) => m['id'] == _selectedMarketId)['name']}\n'
                   '股票代码: ${_stockCodeController.text}\n'
                   '委托价格: ${_priceController.text}\n'
                   '委托数量: ${_quantityController.text}';
      } else if (_selectedAction == TradeAction.cancel) {
        // 撤单可能需要订单号，这里简化处理 (Cancel might need order ID, simplified here)
        message += '股票代码 (用于定位订单): ${_stockCodeController.text}';
      } else if (_selectedAction == TradeAction.query) {
        // 查询也可能需要更多参数 (Query might also need more parameters)
         message += '查询条件 (如股票代码): ${_stockCodeController.text}';
      }


      // 显示一个简单的对话框或 SnackBar (Show a simple dialog or SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请求已提交！\n$message', style: const TextStyle(fontSize: 12)),
          duration: const Duration(seconds: 3),
        ),
      );

      // 提交成功后可以考虑清空表单 (Consider clearing the form after successful submission)
      // _formKey.currentState?.reset();
      // _stockCodeController.clear();
      // _quantityController.clear();
      // _priceController.clear();
      // setState(() {
      //   _selectedAccountId = null;
      //   _selectedMarketId = null;
      //   _selectedAction = TradeAction.buy;
      // });
    }
  }

  // 根据选择的操作动态显示/隐藏价格和数量字段 (Dynamically show/hide price and quantity fields based on selected action)
  bool _showPriceAndQuantityFields() {
    return _selectedAction == TradeAction.buy || _selectedAction == TradeAction.sell;
  }
  bool _showStockCodeField() {
    return _selectedAction == TradeAction.buy || _selectedAction == TradeAction.sell || _selectedAction == TradeAction.cancel || _selectedAction == TradeAction.query;
  }
  bool _showMarketField() {
     return _selectedAction == TradeAction.buy || _selectedAction == TradeAction.sell;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('委托下单/查询'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // 允许内容滚动 (Allow content to scroll)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. 选择账户 (Account Selection)
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('选择账户'),
                  value: _selectedAccountId,
                  hint: const Text('请选择交易账户'),
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

                // 2. 操作选择 (Action Selection - Buy, Sell, Cancel, Query)
                SegmentedButton<TradeAction>(
                  segments: const <ButtonSegment<TradeAction>>[
                    ButtonSegment<TradeAction>(value: TradeAction.buy, label: Text('买入'), icon: Icon(Icons.add_shopping_cart)),
                    ButtonSegment<TradeAction>(value: TradeAction.sell, label: Text('卖出'), icon: Icon(Icons.sell_outlined)),
                    ButtonSegment<TradeAction>(value: TradeAction.cancel, label: Text('撤单'), icon: Icon(Icons.cancel_schedule_send_outlined)),
                    ButtonSegment<TradeAction>(value: TradeAction.query, label: Text('查询'), icon: Icon(Icons.find_in_page_outlined)),
                  ],
                  selected: {_selectedAction},
                  onSelectionChanged: (Set<TradeAction> newSelection) {
                    setState(() {
                      _selectedAction = newSelection.first;
                      // 清理不必要的字段 (Clear unnecessary fields)
                      if (!_showPriceAndQuantityFields()) {
                        _priceController.clear();
                        _quantityController.clear();
                      }
                      if (!_showMarketField()) {
                        _selectedMarketId = null;
                      }
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    selectedBackgroundColor: Colors.deepPurple.withOpacity(0.2),
                    selectedForegroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),


                // 3. 股票代码 (Stock Code Input)
                if(_showStockCodeField())
                  TextFormField(
                    controller: _stockCodeController,
                    decoration: _inputDecoration('股票代码', prefixIcon: Icons.bar_chart),
                    keyboardType: TextInputType.text, // 根据实际代码格式调整 (Adjust based on actual code format)
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入股票代码';
                      }
                      return null;
                    },
                  ),
                if(_showStockCodeField()) const SizedBox(height: 16),

                // 4. 选择市场 (Market Selection)
                if (_showMarketField())
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('选择市场'),
                    value: _selectedMarketId,
                    hint: const Text('请选择交易市场'),
                    items: _markets.map((market) {
                      return DropdownMenuItem<String>(
                        value: market['id'],
                        child: Text(market['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMarketId = value;
                      });
                    },
                    validator: (value) {
                      if (_showMarketField() && value == null) {
                        return '请选择一个市场';
                      }
                      return null;
                    },
                  ),
                if (_showMarketField()) const SizedBox(height: 16),


                // 5. 委托价格 (Order Price Input)
                if (_showPriceAndQuantityFields())
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('委托价格', prefixIcon: Icons.attach_money),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (_showPriceAndQuantityFields()) {
                        if (value == null || value.isEmpty) {
                          return '请输入委托价格';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return '请输入有效的价格';
                        }
                      }
                      return null;
                    },
                  ),
                if (_showPriceAndQuantityFields()) const SizedBox(height: 16),

                // 6. 委托数量 (Order Quantity Input)
                if (_showPriceAndQuantityFields())
                  TextFormField(
                    controller: _quantityController,
                    decoration: _inputDecoration('委托数量', prefixIcon: Icons.format_list_numbered),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done, // 表单的最后一个输入 (Last input in the form)
                    validator: (value) {
                       if (_showPriceAndQuantityFields()) {
                        if (value == null || value.isEmpty) {
                          return '请输入委托数量';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return '请输入有效的数量';
                        }
                      }
                      return null;
                    },
                  ),
                if (_showPriceAndQuantityFields()) const SizedBox(height: 24),


                // 7. 提交按钮 (Submit Button)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)
                    )
                  ),
                  onPressed: _isLoading ? null : _submitTrade, // 正在加载时禁用 (Disable when loading)
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Text(_getSubmitButtonText()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 辅助方法获取提交按钮文本 (Helper method to get submit button text)
  String _getSubmitButtonText() {
    switch (_selectedAction) {
      case TradeAction.buy:
        return '买入';
      case TradeAction.sell:
        return '卖出';
      case TradeAction.cancel:
        return '提交撤单';
      case TradeAction.query:
        return '查询';
      default:
        return '提交';
    }
  }

  // 辅助方法创建输入框样式 (Helper method to create input decoration)
  InputDecoration _inputDecoration(String labelText, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.deepPurple[200]) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.deepPurple.withOpacity(0.05),
    );
  }
}
