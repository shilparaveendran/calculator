import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/calculator_controller.dart';
import '../widgets/calculator_button.dart';
import '../widgets/display_panel.dart';

class CalculatorView extends GetView<CalculatorController> {
  const CalculatorView({super.key});
  static const Color _navyBlue = Color(0xFF0B2E6D);

  // Standard calculator layout ordered top-left to bottom-right.
  static const List<String> _keys = <String>[
    'C',
    'DEL',
    '()',
    '%',
    '7',
    '8',
    '9',
    'x',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '/',
    '=',
  ];

  static const Set<String> _operatorLabels = <String>{
    '+',
    '-',
    'x',
    '/',
    '%',
    'C',
    'DEL',
    '()',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        toolbarHeight: 56,
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Precision',
            icon: const Icon(Icons.tune),
            onSelected: controller.updatePrecision,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text('No precision')),
              PopupMenuItem(value: 2, child: Text('2 decimals')),
              PopupMenuItem(value: 4, child: Text('4 decimals')),
              PopupMenuItem(value: 6, child: Text('6 decimals')),
            ],
          ),
          IconButton(
            tooltip: 'History',
            onPressed: controller.showHistoryBottomSheet,
            icon: const Icon(Icons.history),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Toggle theme',
              onPressed: controller.toggleTheme,
              icon: Icon(
                controller.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 400;
              final double gridGap = compact ? 4 : 6;
              final int displayFlex = compact ? 26 : 30;
              final int keypadFlex = compact ? 74 : 70;
              return Column(
                children: [
                  Obx(
                    () => Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _navyBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          controller.precision.value == 0
                              ? 'Precision: No precision'
                              : 'Precision: ${controller.precision.value}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _navyBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: displayFlex,
                    child: Obx(
                      () => DisplayPanel(
                        expression: controller.expression.value,
                        preview: controller.displayValue.value,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Expanded(
                    flex: keypadFlex,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keys.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: gridGap,
                        crossAxisSpacing: gridGap,
                        childAspectRatio: compact ? 1.08 : 1.03,
                      ),
                      itemBuilder: (_, int index) {
                        final String label = _keys[index];
                        return CalculatorButton(
                          label: label,
                          onTap: () => controller.onButtonPressed(label),
                          isPrimary: label == '=',
                          isOperator:
                              label != '=' && _operatorLabels.contains(label),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
