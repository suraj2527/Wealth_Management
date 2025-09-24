import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wealth_app/utils/constants/text_styles.dart';
import 'package:wealth_app/utils/Theme/theme_extension.dart';

class ConsentDialog extends StatefulWidget {
  final String title;
  final String content;
  final String agreeText;
  final String disagreeText;
  final VoidCallback onAgree;
  final VoidCallback onDisagree;

  const ConsentDialog({
    super.key,
    required this.title,
    required this.content,
    required this.agreeText,
    required this.disagreeText,
    required this.onAgree,
    required this.onDisagree,
  });

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool isAgreed = false;
  bool isScrolledToEnd = false;

  final ScrollController _scrollController = ScrollController();

  @override
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll &&
          !_scrollController.position.outOfRange) {
        if (!isScrolledToEnd) {
          setState(() => isScrolledToEnd = true);
        }
      } else {
        if (isScrolledToEnd) {
          setState(() => isScrolledToEnd = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildConsentText() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
          children: const [
            TextSpan(text: "Welcome to "),
            TextSpan(
              text: "Dynamics Monk Pvt. Ltd.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  "\n\nBefore you start using our Wealth Management Services, we request your consent to ",
            ),
            TextSpan(
              text: "Collect, Store and Process",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  " certain Personal and Financial information. This helps us deliver a ",
            ),
            TextSpan(
              text: "secure, personalised and efficient experience",
              // style: TextStyle(fontStyle: FontStyle.italic),
            ),
            TextSpan(
              text:
                  " for you.\n\nWe are committed to protecting your privacy. ",
            ),
            TextSpan(
              text: "Your data will be kept safe",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  " and will only be used in accordance with our Privacy Policy and Terms & Conditions. We will never share your information with third parties without your explicit permission, unless required by law.\n\n",
            ),
            TextSpan(text: "By continuing, you confirm "),
            TextSpan(
              text: "the details you provide are accurate",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: " and that you have read and understood our policies.",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close, color: context.lineColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text(
                            "Exit App",
                            style: TextStyle(fontWeight: AppTextStyle.semiBold),
                          ),
                          content: const Text("Do you really want to exit?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: context.mainFontColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () => exit(0),
                              child: Text(
                                "Exit",
                                style: TextStyle(color: context.buttonColor),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
            SvgPicture.asset('assets/images/main_logo.svg', height: 50),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Divider(color: context.lineColor, thickness: 0.4),
            const SizedBox(height: 12),
            Expanded(
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                radius: const Radius.circular(10),
                thickness: 6,
                thumbColor: context.buttonColor,
                trackColor: context.fieldColor,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _buildConsentText(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isScrolledToEnd
                            ? () {
                              setState(() => isAgreed = true);
                              widget.onAgree();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isScrolledToEnd
                              ? context.buttonColor
                              : Colors.grey[300],
                      foregroundColor:
                          isScrolledToEnd ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(widget.agreeText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => isAgreed = false);
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text(
                                "Notice",
                                style: TextStyle(
                                  fontWeight: AppTextStyle.mediumWeight,
                                ),
                              ),
                              content: const Text(
                                "You must consent to proceed.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      color: context.buttonColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isAgreed ? context.buttonColor : Colors.grey[300],
                      foregroundColor:
                          !isAgreed ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(widget.disagreeText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
