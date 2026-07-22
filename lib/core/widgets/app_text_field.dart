import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.labelText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.alignLabelWithHint = false,
    this.counterText,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String labelText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool? enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool alignLabelWithHint;
  final String? counterText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: _appInputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        alignLabelWithHint: alignLabelWithHint,
        counterText: counterText,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.labelText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.alignLabelWithHint = false,
    this.counterText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    super.key,
  });

  final String labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool? enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool alignLabelWithHint;
  final String? counterText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: _appInputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        alignLabelWithHint: alignLabelWithHint,
        counterText: counterText,
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

InputDecoration _appInputDecoration({
  required String labelText,
  required IconData? prefixIcon,
  required Widget? suffixIcon,
  required String? hintText,
  required bool alignLabelWithHint,
  required String? counterText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    suffixIcon: suffixIcon,
    counterText: counterText,
  );
}
