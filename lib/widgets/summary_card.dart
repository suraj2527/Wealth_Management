import 'package:flutter/material.dart';
import 'package:wealth_app/constants/colors.dart';
// import 'package:wealth_app/constants/font_sizes.dart';
import 'package:wealth_app/constants/text_styles.dart';

class SummaryCard extends StatelessWidget {
  final String amount;
  final double? width;

  const SummaryCard({
    super.key,
    required this.amount,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldcolor,
        border: Border.all(color: AppColors.bordercolor.withOpacity(0.01)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Text(
        '₹ $amount',
        style: const TextStyle(
          fontWeight:AppTextStyle.semiBold,
          fontSize: 20,
          color: AppColors.mainFontColor,
        ),
      ),
    );
  }
}
