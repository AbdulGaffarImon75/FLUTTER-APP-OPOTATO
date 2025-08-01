class SeatStatusModel {
  final int total;
  final int available;
  final int two;
  final int four;
  final int eight;
  final int twelve;

  SeatStatusModel({
    required this.total,
    required this.available,
    required this.two,
    required this.four,
    required this.eight,
    required this.twelve,
  });

  /// Helper to turn `null`, `int`, `double` or numeric `String` into an `int`.
  static int _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory SeatStatusModel.fromMap(Map<String, dynamic> m) {
    return SeatStatusModel(
      total: _parseNum(m['total seats'] ?? m['total']),
      available: _parseNum(m['available seats'] ?? m['available']),
      two: _parseNum(m['2_people_seat'] ?? m['two']),
      four: _parseNum(m['4_people_seat'] ?? m['four']),
      eight: _parseNum(m['8_people_seat'] ?? m['eight']),
      twelve: _parseNum(m['12_people_seat'] ?? m['twelve']),
    );
  }

  Map<String, dynamic> toMap() => {
    'total seats': total,
    'available seats': available,
    '2_people_seat': two,
    '4_people_seat': four,
    '8_people_seat': eight,
    '12_people_seat': twelve,
  };
}
