import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/extension/theme_extension.dart';

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

  final String dummyText =
      List.generate(
        40,
        (index) =>
            "This is a sample consent paragraph for Testing. It ensures scrollbar and scroll interaction work properly.\n\n",
      ).join();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() => isScrolledToEnd = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  child: Text(
                    dummyText,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
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
