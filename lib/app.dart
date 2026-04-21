import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/calculator_controller.dart';
import 'views/calculator_view.dart';

class CalculatorApp extends GetView<CalculatorController> {
  const CalculatorApp({super.key});
  static const Color _navyBlue = Color(0xFF0B2E6D);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Professional Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: _navyBlue),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: _navyBlue,
            iconTheme: IconThemeData(color: _navyBlue),
            actionsIconTheme: IconThemeData(color: _navyBlue),
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: const Color(0xFF0D47A1),
          ),
          scaffoldBackgroundColor: const Color(0xFF061A40),
        ),
        themeMode:
            controller.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        home: const CalculatorView(),
      ),
    );
  }
}
