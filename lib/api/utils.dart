extension MapExtension on Map<String, dynamic> {
  int? getInt(String key) {
    var value = this[key];
    if (value is int) {
      return value;
    }
    // 如果值是 double 类型，并且它实际上是一个整数（例如 30.0），可以尝试转换为 int
    if (value is double) {
      if (value == value.toInt()) {
        // 检查是否是整数 double (e.g., 30.0)
        return value.toInt();
      }
    }
    return null; // 如果不是 int 也不是整数 double，或者键不存在，返回 null
  }

  double? getDouble(String key) {
    var value = this[key];
    if (value is double) {
      return value;
    }
    if (value is int) {
      // int 可以直接转 double
      return value.toDouble();
    }
    if (value is String) {
      // 字符串尝试解析
      return double.tryParse(value);
    }
    return null; // 其他类型或键不存在时返回 null
  }
}
