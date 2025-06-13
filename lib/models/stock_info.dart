import 'package:myapp/api/utils.dart';

class StockInfo {
  final String code;
  final String name;
  final int holdings;
  final int available;
  final double costPrice;
  final double currentPrice;
  final double profitLoss;
  final double lossPercent;
  final int lockedamount;
  final int buyamount;

  StockInfo({
    required this.code,
    required this.name,
    required this.holdings,
    required this.available,
    required this.costPrice,
    required this.currentPrice,
    required this.profitLoss,
    required this.lossPercent,
    required this.lockedamount,
    required this.buyamount,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      code: json['stock_code'],
      name: json['stock_name'],
      holdings: json.getInt('quantity') ?? 0,
      available: json.getInt('usedstock') ?? 0,
      costPrice: json.getDouble('price') ?? 0.0,
      currentPrice: json.getDouble('now_price') ?? 0.0,
      profitLoss: json.getDouble('loss') ?? 0.0,
      lossPercent: json.getDouble('loss_per') ?? 0.0,
      lockedamount: json.getInt('lock_quantity') ?? 0,
      buyamount: json.getInt('buy_quantity') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'holdings': holdings,
      'available': available,
      'costPrice': costPrice,
      'currentPrice': currentPrice,
      'profitLoss': profitLoss,
      'lossPercent': lossPercent,
      'lockedamount': lockedamount,
      'buyamount': buyamount,
    };
  }
}
