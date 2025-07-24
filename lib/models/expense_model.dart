class ExpenseModel {
  final String year;
  final String type;
  final String subCategory;
  final String period;
  final String natureType;
  final String amount;
  final String date;

  ExpenseModel({
    required this.year,
    required this.type,
    required this.subCategory,
    required this.period,
    required this.natureType,
    required this.amount,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      year: json['year'] ?? '',
      type: json['type'] ?? '',
      subCategory: json['subCategory'] ?? '',
      period: json['period'] ?? '',
      natureType: json['natureType'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'type': type,
      'subCategory': subCategory,
      'period': period,
      'natureType': natureType,
      'amount': amount,
      'date': date,
    };
  }
}
