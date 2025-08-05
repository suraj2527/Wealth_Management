class AssetModel {
  final String userId;
  final String startDate;
  final String endDate;
  final String investmentCategory;
  final String investmentSubCategory;
  final String investmentFundName;
  final double amount;
  final String id;
  double get currentValue => amount;

  AssetModel({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.investmentCategory,
    required this.investmentSubCategory,
    required this.investmentFundName,
    required this.amount,
    required this.id,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      userId: json['userId'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      investmentCategory: json['investmentCategory'] ?? '',
      investmentSubCategory: json['investmentSubCategory'] ?? '',
      investmentFundName: json['investmentFundName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'investmentCategory': investmentCategory,
      'investmentSubCategory': investmentSubCategory,
      'investmentFundName': investmentFundName,
      'amount': amount,
    };
  }
}
