import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calc_history_entry.dart';

class CalculatorController extends GetxController {
  CalculatorController(this._prefs) {
    _loadPersistedState();
  }

  static const String _precisionKey = 'precision';
  static const String _historyKey = 'history';
  static const String _darkModeKey = 'darkMode';

  final SharedPreferences _prefs;
  final RxString expression = '0'.obs;
  final RxString displayValue = '0'.obs;
  final RxInt precision = 2.obs;
  final RxBool isDarkMode = false.obs;
  final RxList<CalcHistoryEntry> historyEntries = <CalcHistoryEntry>[].obs;

  final Set<String> _operators = {'+', '-', 'x', '/', '%'};

  void _snackbar(String title, String message) {
    final bool dark = isDarkMode.value;
    final Color bg = dark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB);
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.35 : 0.18),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
    );
  }

  void onButtonPressed(String value) {
    if (_isDigit(value)) {
      _appendDigit(value);
      return;
    }

    switch (value) {
      case '.':
        _appendDecimal();
        break;
      case 'C':
        clearAll();
        break;
      case 'DEL':
        backspace();
        break;
      case '=':
        evaluateExpression();
        break;
      case '()':
        _appendBracketSmart();
        break;
      default:
        _appendOperator(value);
        break;
    }
  }

  void clearAll() {
    expression.value = '0';
    displayValue.value = '0';
  }

  void backspace() {
    if (expression.value.length == 1) {
      clearAll();
      return;
    }
    expression.value =
        expression.value.substring(0, expression.value.length - 1);
    _syncPreview();
  }

  void evaluateExpression() {
    if (_openParenBalance(expression.value) != 0) {
      _snackbar('Invalid expression', 'Close all parentheses before =.');
      return;
    }
    if (_endsWithOperator(expression.value)) {
      _snackbar('Invalid expression', 'Expression cannot end with an operator.');
      return;
    }

    final String original = expression.value;
    try {
      final double result = _evaluate(expression.value);
      expression.value = _formatNumber(result);
      displayValue.value = expression.value;
      if (_shouldStoreHistory(original, displayValue.value)) {
        _addToHistory('$original = ${displayValue.value}');
      }
    } catch (_) {
      _snackbar('Calculation error', 'Please check your input and try again.');
    }
  }

  void updatePrecision(int decimals) {
    precision.value = decimals;
    _prefs.setInt(_precisionKey, decimals);
    _syncPreview();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.setBool(_darkModeKey, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  String historySectionLabel(DateTime at) {
    if (at.millisecondsSinceEpoch == 0) {
      return 'Earlier';
    }
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(at.year, at.month, at.day);
    if (day == today) {
      return 'Today';
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[at.month - 1]} ${at.day}, ${at.year}';
  }

  void showHistoryBottomSheet() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.72,
        child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text('History', style: Get.textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: clearHistory,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (historyEntries.isEmpty) {
                  return Center(
                    child: Text(
                      'No calculations yet',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final List<Widget> tiles = <Widget>[];
                String? lastLabel;
                for (final CalcHistoryEntry entry in historyEntries) {
                  final String label = historySectionLabel(entry.at);
                  if (label != lastLabel) {
                    if (tiles.isNotEmpty) {
                      tiles.add(const SizedBox(height: 20));
                    }
                    tiles.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          label,
                          style: Get.textTheme.titleSmall?.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    );
                    lastLabel = label;
                  }
                  tiles.add(
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Get.theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        entry.text,
                        style: Get.textTheme.bodyLarge,
                        softWrap: true,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: EdgeInsets.zero,
                  children: tiles,
                );
              }),
            ),
          ],
        ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void clearHistory() {
    historyEntries.clear();
    _prefs.setString(_historyKey, jsonEncode(<Map<String, dynamic>>[]));
  }

  void _appendDigit(String value) {
    if (expression.value == '0') {
      expression.value = value;
    } else {
      expression.value += value;
    }
    _syncPreview();
  }

  void _appendDecimal() {
    final String currentNumber = _currentNumberSuffix(expression.value);
    if (currentNumber.contains('.')) {
      _snackbar('Invalid decimal', 'Only one decimal is allowed per number.');
      return;
    }
    if (_endsWithOperator(expression.value)) {
      expression.value += '0.';
    } else {
      expression.value += '.';
    }
    _syncPreview();
  }

  void _appendBracketSmart() {
    final String expr = expression.value;
    final int openBalance = _openParenBalance(expr);
    final String last = expr.isNotEmpty ? expr[expr.length - 1] : '';

    if (expr == '0' || _operators.contains(last) || last == '(') {
      _appendOpenParen();
      return;
    }

    if (_isDigit(last) || last == ')') {
      if (openBalance > 0) {
        _appendCloseParen();
      } else {
        _appendOpenParen();
      }
      return;
    }

    _appendOpenParen();
  }

  void _appendOpenParen() {
    if (expression.value == '0') {
      expression.value = '(';
      _syncPreview();
      return;
    }
    final String last = expression.value[expression.value.length - 1];
    if (last == '.') {
      _snackbar('Invalid input', 'Complete the number before "(".');
      return;
    }
    if (_isDigit(last) || last == ')') {
      expression.value += 'x(';
    } else if (_operators.contains(last) || last == '(') {
      expression.value += '(';
    }
    _syncPreview();
  }

  void _appendCloseParen() {
    if (_openParenBalance(expression.value) <= 0) {
      _snackbar('Mismatched parentheses', 'No matching "(" for ")".');
      return;
    }
    final String last = expression.value[expression.value.length - 1];
    if (last == '(') {
      _snackbar('Invalid input', 'Put a value inside parentheses.');
      return;
    }
    if (_operators.contains(last)) {
      _snackbar('Invalid input', 'Complete the expression before ")".');
      return;
    }
    expression.value += ')';
    _syncPreview();
  }

  void _appendOperator(String operator) {
    if (!_operators.contains(operator)) {
      return;
    }
    if (_endsWithOperator(expression.value)) {
      _snackbar(
        'Invalid input',
        'Two operators cannot be entered together.',
      );
      return;
    }
    final String last =
        expression.value.isNotEmpty ? expression.value[expression.value.length - 1] : '';
    if (last == '(') {
      _snackbar('Invalid input', 'Enter a number before an operator.');
      return;
    }
    expression.value += operator;
    _syncPreview();
  }

  void _syncPreview() {
    if (_openParenBalance(expression.value) != 0) {
      displayValue.value = expression.value;
      return;
    }
    if (_endsWithOperator(expression.value)) {
      displayValue.value = expression.value;
      return;
    }

    try {
      final double result = _evaluate(expression.value);
      displayValue.value = _formatNumber(result);
    } catch (_) {
      displayValue.value = expression.value;
    }
  }

  double _evaluate(String exp) {
    final List<String> tokens = _tokenize(exp);
    final List<String> postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  List<String> _tokenize(String exp) {
    final List<String> tokens = <String>[];
    String number = '';

    for (int i = 0; i < exp.length; i++) {
      final String char = exp[i];
      if (char == '(' || char == ')') {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = '';
        }
        tokens.add(char);
        continue;
      }
      if (_isDigit(char) || char == '.') {
        number += char;
      } else {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = '';
        }
        tokens.add(char);
      }
    }

    if (number.isNotEmpty) {
      tokens.add(number);
    }

    return tokens;
  }

  List<String> _toPostfix(List<String> tokens) {
    final List<String> output = <String>[];
    final List<String> stack = <String>[];

    for (final String token in tokens) {
      if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) {
          throw StateError('Mismatched parentheses');
        }
        stack.removeLast();
      } else if (_operators.contains(token)) {
        while (stack.isNotEmpty &&
            stack.last != '(' &&
            _precedence(stack.last) >= _precedence(token)) {
          output.add(stack.removeLast());
        }
        stack.add(token);
      } else {
        output.add(token);
      }
    }

    while (stack.isNotEmpty) {
      final String top = stack.removeLast();
      if (top == '(' || top == ')') {
        throw StateError('Mismatched parentheses');
      }
      output.add(top);
    }

    return output;
  }

  double _evaluatePostfix(List<String> postfix) {
    final List<double> stack = <double>[];

    for (final String token in postfix) {
      if (_operators.contains(token)) {
        if (stack.length < 2) {
          throw StateError('Malformed expression');
        }

        final double b = stack.removeLast();
        final double a = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case 'x':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0) {
              throw StateError('Division by zero');
            }
            stack.add(a / b);
            break;
          case '%':
            if (b == 0) {
              throw StateError('Modulo by zero');
            }
            stack.add(a % b);
            break;
        }
      } else {
        stack.add(double.parse(token));
      }
    }

    if (stack.length != 1) {
      throw StateError('Malformed expression');
    }
    return stack.single;
  }

  int _precedence(String operator) {
    if (operator == '+' || operator == '-') {
      return 1;
    }
    return 2;
  }

  bool _isDigit(String value) => RegExp(r'^[0-9]$').hasMatch(value);

  int _openParenBalance(String value) {
    int balance = 0;
    for (int i = 0; i < value.length; i++) {
      if (value[i] == '(') {
        balance++;
      } else if (value[i] == ')') {
        balance--;
      }
    }
    return balance;
  }

  bool _endsWithOperator(String value) {
    return value.isNotEmpty && _operators.contains(value[value.length - 1]);
  }

  bool _shouldStoreHistory(String expressionText, String resultText) {
    final bool hasOperation = RegExp(r'[+\-x/%()]').hasMatch(expressionText);
    if (!hasOperation) {
      return false;
    }
    return expressionText != resultText;
  }

  String _currentNumberSuffix(String value) {
    if (value.isEmpty) {
      return '';
    }
    int i = value.length - 1;
    while (i >= 0) {
      final String c = value[i];
      if (_isDigit(c) || c == '.') {
        i--;
        continue;
      }
      break;
    }
    return value.substring(i + 1);
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(precision.value);
  }

  void _addToHistory(String entry) {
    historyEntries.insert(
      0,
      CalcHistoryEntry(text: entry, at: DateTime.now()),
    );
    if (historyEntries.length > 50) {
      historyEntries.removeLast();
    }
    _persistHistory();
  }

  void _persistHistory() {
    final List<Map<String, dynamic>> encoded = historyEntries
        .map((CalcHistoryEntry e) => e.toJson())
        .toList(growable: false);
    _prefs.setString(_historyKey, jsonEncode(encoded));
  }

  void _loadPersistedState() {
    final int? savedPrecision = _prefs.getInt(_precisionKey);
    final bool? savedTheme = _prefs.getBool(_darkModeKey);
    final String? savedHistoryJson = _prefs.getString(_historyKey);

    if (savedPrecision != null && [2, 4, 6].contains(savedPrecision)) {
      precision.value = savedPrecision;
    }
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    }
    if (savedHistoryJson != null && savedHistoryJson.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(savedHistoryJson);
        if (decoded is List<dynamic>) {
          final List<CalcHistoryEntry> loaded = <CalcHistoryEntry>[];
          for (final dynamic item in decoded) {
            if (item is String) {
              loaded.add(
                CalcHistoryEntry(
                  text: item,
                  at: DateTime.fromMillisecondsSinceEpoch(0),
                ),
              );
            } else if (item is Map) {
              loaded.add(
                CalcHistoryEntry.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }
          historyEntries.value = loaded;
        }
      } catch (_) {
        historyEntries.clear();
      }
    }
  }
}
