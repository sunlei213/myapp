import 'stock_info.dart';

class Account {
  final String id;
  final String name;
  final double balance;
  final List<StockInfo> stocks;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.stocks,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    var list = json['stocks'] as List;
    List<StockInfo> stockList = list.map((i) => StockInfo.fromJson(i)).toList();

    return Account(
      id: json['id'],
      name: json['name'],
      balance: json['balance'].toDouble(),
      stocks: stockList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'stocks': stocks.map((stock) => stock.toJson()).toList(),
    };
  }
}
