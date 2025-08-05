class IncomeModel {
  final String userId;
  final String id;
  final String incomeType;
  final double amount;
  final String period;
  final String startDate;
  final double expectedAnnualIncrementPercentage;
  final String endDate;
  final int year;

  IncomeModel({
    required this.userId,
    required this.incomeType,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.expectedAnnualIncrementPercentage,
    required this.endDate,
    required this.year,
    required this.id,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      userId: json['userId'] ?? '',
      incomeType: json['incomeType'] ?? '',
      amount: _parseAmount(json['amount']),
      period: json['period'] ?? '',
      startDate: json['startDate'] ?? '',
      expectedAnnualIncrementPercentage: _parseAmount(json['expectedAnnualIncrementPercentage']),
      endDate: json['endDate'] ?? '',
      year: json['year'] ?? 0,
      id: json['id']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'incomeType': incomeType,
      'amount': amount,
      'period': period,
      'startDate': startDate,
      'expectedAnnualIncrementPercentage': expectedAnnualIncrementPercentage,
      'endDate': endDate,
      'year': year,
    };
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
