import 'package:flutter/material.dart';

import '../res/app_colors.dart';
class Button extends StatefulWidget {
  final String text;
  final void Function()? onPressed;
  final Color? color;

  const Button({
    required this.text,
    this.onPressed,
    this.color,
    super.key,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return


      MaterialButton(
        color:widget.color?? orange,
            height: 50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            minWidth: double.infinity,
        onPressed:widget.onPressed,


          child: Text(
            widget.text,
            style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),

    );
  }
}
