import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isOperator = false,
    super.key,
  });
  // Centralized palette keeps button states consistent across themes.
  static const Color _lightNumberBlue = Color(0xFFDDF1FF);
  static const Color _darkNumberBlue = Color(0xFFBFDBFE);
  static const Color _lightOperatorBlue = Color(0xFF1565C0);
  static const Color _darkOperatorBlue = Color(0xFF0D47A1);
  static const Color _lightEqualsBlue = Color(0xFF0B3D91);
  static const Color _darkEqualsBlue = Color(0xFF1E88E5);
  static const Color _numberTextNavy = Color(0xFF0B1F5E);

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isOperator;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool darkMode = brightness == Brightness.dark;
    Color fillColor = darkMode ? _darkNumberBlue : _lightNumberBlue;
    Color textColor = _numberTextNavy;

    if (isOperator) {
      fillColor = darkMode ? _darkOperatorBlue : _lightOperatorBlue;
      textColor = Colors.white;
    }
    if (isPrimary) {
      fillColor = darkMode ? _darkEqualsBlue : _lightEqualsBlue;
      textColor = Colors.white;
    }

    final TextStyle textStyle = TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    return Material(
      color: fillColor,
      elevation: 0.5,
      shadowColor: Colors.black12,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: Text(label, style: textStyle),
        ),
      ),
    );
  }
}
