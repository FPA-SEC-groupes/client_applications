import 'package:flutter/material.dart';

import '../res/app_colors.dart';
class DropdownField extends StatefulWidget {
  final String hint;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final String? selectedItem;
  final String? Function(String?)? validator;
  const DropdownField({required this.hint, required this.items, this.onChanged, this.selectedItem, required this.validator});

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(

        contentPadding: EdgeInsets.all(14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  const BorderSide(
              color: gray,
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  const BorderSide(
              color: orange,
            )),
        hintText: widget.hint,
        isDense: true, //
      ),
      hint:Text(widget.hint) ,
      items: widget.items,
      onChanged: widget.onChanged,
      value: widget.selectedItem,
      validator:widget.validator,
    );
  }
}
