import 'package:flutter/material.dart';
import 'package:kayros/res/custom_colors.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputAction,
    this.label,
    this.hint,
    this.validator,
    this.isObscure = false,
    this.isCapitalized = false,
    this.maxLines = 1,
    this.isLabelEnabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? inputAction;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool isObscure;
  final bool isCapitalized;
  final int maxLines;
  final bool isLabelEnabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: isObscure,
      textCapitalization: isCapitalized
          ? TextCapitalization.words
          : TextCapitalization.none,
      textInputAction: inputAction,
      cursorColor: Palette.firebaseYellow,
      validator: validator,
      decoration: InputDecoration(
        labelText: isLabelEnabled ? label : null,
        labelStyle: const TextStyle(color: Palette.firebaseYellow),
        hintText: hint,
        hintStyle: TextStyle(
          color: Palette.firebaseGrey.withValues(alpha: 0.5),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Palette.firebaseAmber, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Palette.firebaseGrey.withValues(alpha: 0.5),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
