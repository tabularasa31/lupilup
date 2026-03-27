import 'package:flutter/material.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
              actions: actions,
            ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFFFFFBF8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

