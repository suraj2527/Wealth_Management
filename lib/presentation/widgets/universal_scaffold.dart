import 'package:flutter/material.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/presentation/widgets/network_widget.dart';
import 'package:wealth_app/presentation/widgets/side_menu_drawer.dart';
import 'package:wealth_app/presentation/widgets/universal_appbar.dart';

class UniversalScaffold extends StatelessWidget {
  final Widget body;

  const UniversalScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: const UniversalAppBar(),
        drawer: const SideMenuDrawer(),
        body: SafeArea(child: body),
      ),
    );
  }
}
