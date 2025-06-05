class StockInfo {
  final String code;
  final String name;
  final double holdings;
  final double available;
  final double costPrice;
  final double currentPrice;
  final double profitLoss;

  StockInfo({
    required this.code,
    required this.name,
    required this.holdings,
    required this.available,
    required this.costPrice,
    required this.currentPrice,
    required this.profitLoss,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      code: json['code'],
      name: json['name'],
      holdings: json['holdings'].toDouble(),
      available: json['available'].toDouble(),
      costPrice: json['costPrice'].toDouble(),
      currentPrice: json['currentPrice'].toDouble(),
      profitLoss: json['profitLoss'].toDouble(),
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
    };
  }
}
