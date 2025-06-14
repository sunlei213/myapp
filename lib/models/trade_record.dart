import 'package:myapp/api/utils.dart';

class TradeRecord {
  final String userId;
  final String code;
  final String name;
  final String type; // 'buy' or 'sell'
  final int volume;
  final double price;
  final double price1; // 成交价格 (Deal price)
  final int volume1; // 成交数量 (Deal volume)
  final int returnVol; // 撤单数量 (Return volume)
  final String date;
  final String time;
  final String status; // 状态 (Status)
  final String msg; // 消息 (Message)
  final String market; // 市场 (Market)

  TradeRecord({
    required this.userId,
    required this.code,
    required this.name,
    required this.type,
    required this.volume,
    required this.price,
    required this.price1,
    required this.volume1,
    required this.returnVol,
    required this.date,
    required this.time,
    required this.status,
    required this.msg,
    required this.market,
  });



  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      userId: json['user_id'].toString(),
      code: json['stock_code']??'',
      name: json['stock_name']??'',
      type: json['type']??'',
      volume: json.getInt('volume') ?? 0,
      price: json.getDouble('price') ?? 0.0,
      price1: json.getDouble('price1') ?? 0.0,
      volume1: json.getInt('volume1') ?? 0,
      returnVol: json.getInt('returnVol') ?? 0,
      date: json['day']??'',
      time: json['time']??'',
      status: json['status']??'',
      msg: json['msg']??'',
      market: json['market']??'',
    );
  }
}
