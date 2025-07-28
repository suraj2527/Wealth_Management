import 'package:flutter/material.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class DotLoader extends StatefulWidget {
  const DotLoader({super.key});

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.3, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();

    for (int i = 0; i < _controllers.length; i++) {
      _startAnimation(i);
    }
  }

  void _startAnimation(int index) async {
    await Future.delayed(Duration(milliseconds: index * 200));
    _controllers[index].repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_animations.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (_, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.buttonColor, // using theme extension
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
