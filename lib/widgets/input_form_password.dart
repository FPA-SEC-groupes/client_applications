import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../res/app_colors.dart';
class InputFormPassword extends StatefulWidget {

  final String? hint;
  final Widget? prefixIcon;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;

  const InputFormPassword({
    this.hint,
    this.prefixIcon,
    this.keyboard,
    this.action,
    this.onSaved,
    this.validator,
    this.contentPadding,
    this.controller,
    this.onChanged,
    super.key,
  });
  @override
  State<InputFormPassword> createState() => _InputFormPasswordState();
}

class _InputFormPasswordState extends State<InputFormPassword> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border:OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color:gray,
            )),
        focusedBorder:OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color:orange,
            )
        ),
        prefixIcon: widget.prefixIcon,
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        isDense: true,                      // Added this

      ),
        validator:widget.validator,
      controller: widget.controller,
      onChanged:widget.onChanged ,

    );
  }
}
