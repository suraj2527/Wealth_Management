import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wealth_app/extension/theme_extension.dart';

void showNotificationDialog(BuildContext context) {
  final List<Map<String, String>> notifications = List.generate(
    12,
    (index) => {
      "title": "Fleur commented in Dashboard 2.0",
      "time": "Friday 3:12 PM",
      "message":
          "Really love this approach. I think this is the best solution for the document sync issue.",
      "ago": "2 hours ago",
    },
  );

  final ScrollController scrollController = ScrollController();

  showGeneralDialog(
    context: context,
    barrierLabel: "Notification",
    barrierDismissible: true,
    barrierColor: Colors.white.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final media = MediaQuery.of(context).size;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 9),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: media.width * 0.92,
                  height: media.height * 0.6,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(maxHeight: media.height * 0.85),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.borderColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Notifications",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: RawScrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 2,
                          radius: const Radius.circular(10),
                          thumbColor: context.buttonColor,
                          trackColor: context.fieldColor,
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: context.fieldColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.borderColor.withOpacity(0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification["title"]!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: context.buttonColor,
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification["time"]!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      notification["message"]!,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      notification["ago"]!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
