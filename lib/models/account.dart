import 'package:flutter/material.dart';
import 'stock_info.dart';
import 'package:myapp/api/utils.dart';

class Account {
  final int userid;
  final String name;
  final double balance;
  final double usedmoney;
  final double getmoney;
  final double stocksvalue;
  final double totlemoney;
  final List<StockInfo> stocks;

  Account({
    required this.userid,
    required this.name,
    required this.balance,
    required this.usedmoney,
    required this.getmoney,
    required this.stocksvalue,
    required this.totlemoney,
    required this.stocks,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    var list = json['stocks'] as List;
    Map<String, dynamic> userMap = json['user'] as Map<String, dynamic>;
    List<StockInfo> stockList = list.map((i) => StockInfo.fromJson(i)).toList();

    return Account(
      userid: userMap.getInt('user_id') ?? 537,
      name: userMap['username'],
      balance: userMap.getDouble('balance') ?? 0.0,
      usedmoney: userMap.getDouble('usedmoney') ?? 0.0,
      getmoney: userMap.getDouble('getmoney') ?? 0.0,
      stocksvalue: userMap.getDouble('stocksvalue') ?? 0.0,
      totlemoney: userMap.getDouble('totlemoney') ?? 0.0,
      stocks: stockList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userid,
      'name': name,
      'balance': balance,
      'usedmoney': usedmoney,
      'getmoney': getmoney,
      'stocksvalue': stocksvalue,
      'totlemoney': totlemoney,
      'stocks': stocks.map((stock) => stock.toJson()).toList(),
    };
  }
}
