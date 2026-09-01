import 'package:flutter/material.dart';

class OuvidoriaFormStyle {
  static const background = Color(0xFFF7F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF202322);
  static const muted = Color(0xFF697370);
  static const border = Color(0xFFE9EDF0);
  static const accent = Color(0xFFD62828);
  static const infoBackground = Color(0x0FD62828);
  static const inputBackground = Color(0xFFFEFFFE);

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    bool alignLabelWithHint = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      isDense: true,
      filled: true,
      fillColor: inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _border(border),
      enabledBorder: _border(border),
      focusedBorder: _border(accent, width: 1.2),
      errorBorder: _border(accent),
      focusedErrorBorder: _border(accent, width: 1.2),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
