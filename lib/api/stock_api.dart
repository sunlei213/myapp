
import 'package:myapp/models/account.dart';
import 'package:myapp/models/trade_record.dart';
import 'package:myapp/models/stock_info.dart';

class StockApi {
  final String baseUrl;
  final String apiKey;

  StockApi({required this.baseUrl, required this.apiKey});

  Future<Account?> fetchAccountInfo(String accountId) async {
    // Placeholder for fetching account info
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (accountId == 'account1') {
      return Account(
        id: 'account1',
        name: 'Account One',
        balance: 100000.0,
        stocks: [
          StockInfo(
            code: 'AAPL',
            name: 'Apple Inc.',
            holdings: 100,
            available: 90,
            costPrice: 150.0,
            currentPrice: 170.0,
            profitLoss: 2000.0,
          ),
          StockInfo(
            code: 'GOOG',
            name: 'Alphabet Inc.',
            holdings: 50,
            available: 45,
            costPrice: 2500.0,
            currentPrice: 2600.0,
            profitLoss: 5000.0,
          ),
        ],
      );
    } else if (accountId == 'account2') {
      return Account(
        id: 'account2',
        name: 'Account Two',
        balance: 50000.0,
        stocks: [
          StockInfo(
            code: 'MSFT',
            name: 'Microsoft Corporation',
            holdings: 200,
            available: 180,
            costPrice: 280.0,
            currentPrice: 300.0,
            profitLoss: 4000.0,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  Future<bool> submitTradeOrder({required String accountId, required String stockCode, required String market, required int quantity, required double price, required String type}) async {
    // Placeholder for submitting trade order
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return true; // Assume success for now
  }

  Future<List<TradeRecord>> fetchTradeHistory({required String accountId, required DateTime startDate, required DateTime endDate}) async {
    // Placeholder for fetching trade history
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      // Dummy trade records
      TradeRecord(id: '1', account: accountId, code: 'AAPL', name: 'Apple Inc.', type: 'buy', quantity: 10, price: 160.0, time: DateTime.now().subtract(const Duration(days: 1))),
      TradeRecord(id: '2', account: accountId, code: 'GOOG', name: 'Alphabet Inc.', type: 'sell', quantity: 5, price: 2550.0, time: DateTime.now().subtract(const Duration(days: 2))),
    ];
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