class TradeRecord {
  final String id;
  final String account;
  final String code;
  final String name;
  final String type; // 'buy' or 'sell'
  final int quantity;
  final double price;
  final DateTime time;

  TradeRecord({
    required this.id,
    required this.account,
    required this.code,
    required this.name,
    required this.type,
    required this.quantity,
    required this.price,
    required this.time,
  });
}
