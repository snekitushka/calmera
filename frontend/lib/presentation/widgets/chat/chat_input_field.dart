import 'package:calmera/presentation/chat_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;


  const ChatInputField({
    required this.controller,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFDDDD),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,         // ← минимальная высота (1 строка)
                  maxLines: 5,         // ← максимальная высота (например, 5 строк)
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Написать",
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.video_camera_front_outlined, color: Color(0xFF2C8955)),
                      onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ChatVideoPage(onSend: onSend)),);},
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF2C8955)),
                      onPressed: () => onSend(controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}