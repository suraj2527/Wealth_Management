class AssetModel {
  final String year;
  final String startDate;
  final String endDate;
  final String category;
  final String subCategory;
  final String fundName;
  final String amount;

  AssetModel({
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.subCategory,
    required this.fundName,
    required this.amount,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      year: json['year'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      fundName: json['fundName'] ?? '',
      amount: json['amount'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'startDate': startDate,
      'endDate': endDate,
      'category': category,
      'subCategory': subCategory,
      'fundName': fundName,
      'amount': amount,
    };
  }
}
