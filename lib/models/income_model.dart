class IncomeModel {
  final String title;
  final String year;
  final double amount;
  final String source;
  final String type;
  final String date;
  final String category;
  final String userId;

  IncomeModel({
    required this.title,
    required this.year,
    required this.amount,
    required this.source,
    required this.type,
    required this.date,
    required this.category,
    required this.userId,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      title: json['title'] ?? '',
      year: json['year'] ?? '',
      amount: _parseAmount(json['amount']),
      source: json['source'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'year': year,
      'amount': amount,
      'source': source,
      'type': type,
      'date': date,
      'category': category,
      'userId': userId,
    };
  }

  static double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is num) return amount.toDouble();
    return double.tryParse(amount.toString()) ?? 0.0;
  }
}
