import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    required this.text,
    required this.isUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Color(0xFF2C8955).withOpacity(.3) : Colors.grey[200],
              borderRadius: isUser ? BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(0), // без скругления
              ) : BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(text,),
          ),
        ),
      ],
    );
  }
}