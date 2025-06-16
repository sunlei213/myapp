import 'package:myapp/models/account.dart';
import 'package:myapp/models/trade_record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class StockApi {
  // 2. 将变量改为私有，使用 _ 前缀
  String _baseUrl;
  String _apiKey;

  // 构造函数现在接收初始值并赋给私有变量
  StockApi({required String baseUrl, required String apiKey})
      : _baseUrl = baseUrl,
        _apiKey = apiKey;

  // 暴露公共的 getter 来获取值
  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;

  // 3. 正确的 setter 实现，将新值赋给私有变量
  set baseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
  }

  set apiKey(String newApiKey) {
    _apiKey = newApiKey;
  }

  Future<Account> fetchAccountInfo(String accountId) async {
    final url = Uri.parse('$_baseUrl/account/$accountId');

    final response = await http.get(url, headers: {'X-API-Key': _apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        return Account.fromJson(data);
      } catch (e) {
        throw Exception('获取错误信息: $e');
      }
    } else {
      throw Exception('获取账户信息失败: ${response.body}');
    }
  }

  Future<bool> submitCommand(
      {required String accountId,
      required String type}) async {
    // Placeholder for submitting trade order
    final url = Uri.parse('$_baseUrl/command/$accountId');
    final response = await http.post(url,
        headers: {'X-API-Key': _apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode({'type': type}));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('错误的命令');
    }
  }

  Future<bool> submitTradeOrder(
      {required String accountId,
      required String stockCode,
      required String market,
      required int volume,
      required double price,
      required String type}) async {
    // Placeholder for submitting trade order
    final url = Uri.parse('$_baseUrl/place_order/$accountId');
    final response = await http.post(url,
        headers: {'X-API-Key': _apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': stockCode,
          'market': market,
          'volume': volume,
          'price': price,
          'type': type
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to submit trade order');
    }
  }

  Future<List<TradeRecord>> fetchTradeHistory(
      {required String accountId, required String startDate, required String endDate}) async {
    // Placeholder for fetching trade history
    final response = await http.get(
      Uri.parse('$_baseUrl/trades/$accountId')
          .replace(queryParameters: {
          'start': startDate,
          'end': endDate,
          }),
        headers: {'X-API-Key': _apiKey, 'Content-Type': 'application/json'},
        );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var list = data['return'] as List;

      try {
        List<TradeRecord> tradeRecords = list.map((i) => TradeRecord.fromJson(i)).toList();
        return tradeRecords;
      } catch (e) {
        throw Exception('获取错误信息: $e');
      }
    } else {
      throw Exception('没有查询到记录');
    }
  }

  Future<List<Map<String, String>>> fetchOption() async {
    final url = Uri.parse('$_baseUrl/form/options');
    try {
      final response = await http.get(url, headers: {'X-API-Key': _apiKey});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var list = data['users'] as List;
        List<Map<String, String>> userList = list.map((i) {
          return {'id': i['value'].toString(), 'name': i['label'].toString()};
        }).toList();
        return userList;
      } else {
        throw Exception('Failed to load account info');
      }
    } catch (e) {
      throw Exception('获取错误信息: $e');
    }
  }

  Future<List<Map<String, String>>> fetchLog() async {
    final url = Uri.parse('$_baseUrl/place_order');
    try {
      final response = await http.get(url, headers: {'X-API-Key': _apiKey});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var list = data['return'] as List;
        List<Map<String, String>> userList = list.map((i) {
          return {'userid': i['stg'].toString(), 'time': i['start_time'].toString(), 'type': i['type'].toString(), 'msg': i['msg'].toString()};
        }).toList();
        return userList;
      } else {
        throw Exception('获取错误信息: ${response.body}');
      }
    } catch (e) {
      throw Exception('获取错误信息: $e');
    }
  }
}
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_stock_app/models/account.dart';
import 'package:my_stock_app/models/trade_record.dart';

class StockApi {
  final String baseUrl;
  final String apiKey;

  StockApi({required this.baseUrl, required this.apiKey});

  Future<Account> fetchAccountInfo(String accountId) async {
    final url = Uri.parse('$baseUrl/account/$accountId');
    final response = await http.get(url, headers: {'X-API-Key': apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Account.fromJson(data);
    } else {
      throw Exception('Failed to load account info');
    }
  }

  Future<bool> submitTradeOrder({
    required String accountId,
    required String stockCode,
    required String market,
    required int quantity,
    required double price,
    required String type, // e.g., 'buy', 'sell', 'cancel'
  }) async {
    final url = Uri.parse('$baseUrl/trade/order');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      },
      body: jsonEncode({
        'accountId': accountId,
        'stockCode': stockCode,
        'market': market,
        'quantity': quantity,
        'price': price,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      return true; // Or parse response for success/failure
    } else {
      throw Exception('Failed to submit trade order');
    }
  }

  Future<List<TradeRecord>> fetchTradeHistory({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse('$baseUrl/trade/history');
    final response = await http.get(
      Uri.parse('$baseUrl/trade/history')
          .replace(queryParameters: {
        'accountId': accountId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      }),
      headers: {'X-API-Key': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TradeRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trade history');
    }
  }
}*/
