import 'package:flutter/material.dart';

import '../../text_styles.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GreenButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C8955),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyles.title,
        ),
      ),
    );
  }
}
