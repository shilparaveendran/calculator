class CalcHistoryEntry {
  CalcHistoryEntry({
    required this.text,
    required this.at,
  });

  final String text;
  final DateTime at;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'at': at.toIso8601String(),
      };

  static CalcHistoryEntry fromJson(Map<String, dynamic> map) {
    return CalcHistoryEntry(
      text: map['text'] as String,
      at: DateTime.parse(map['at'] as String),
    );
  }
}
