// ignore_for_file: non_constant_identifier_names

class ExpenseModel {
  final String userId;
  final String Id;
  final int year;
  final String expenseType;
  final String subCategory;
  final String period;
  final String natureType;
  final double amount;
  final double expectedAnnualIncrementPercentage;
  final String startDate;
  final bool isRecurring;

  ExpenseModel({
    required this.userId,
    required this.year,
    required this.expenseType,
    required this.subCategory,
    required this.period,
    required this.natureType,
    required this.amount,
    required this.expectedAnnualIncrementPercentage,
    required this.startDate,
    required this.isRecurring,
    required this.Id,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      userId: json['userId'] ?? '',
      year: json['Year'] ?? DateTime.now().year,
      expenseType: json['ExpenseType'] ?? 'Null',
      subCategory: json['SubCategory'] ?? 'Null',
      period: json['Period'] ?? '',
      natureType: json['NatureType'] ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      expectedAnnualIncrementPercentage:
          (json['ExpectedAnnualIncrementPercentage'] as num?)?.toDouble() ??
          0.0,
      startDate: json['StartDate'] ?? '',
      isRecurring: json['IsRecurring'] ?? false,
      Id: json['Id']??'Null',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'year': year,
      'expenseType': expenseType,
      'subCategory': subCategory,
      'period': period,
      'natureType': natureType,
      'amount': amount,
      'expectedAnnualIncrementPercentage': expectedAnnualIncrementPercentage,
      'startDate': startDate,
      'isRecurring': isRecurring,
    };
  }
}
