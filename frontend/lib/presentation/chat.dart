import 'package:calmera/presentation/widgets/chat/chat_bubble.dart';
import 'package:calmera/presentation/widgets/chat/chat_input_field.dart';
import 'package:calmera/presentation/widgets/navbar.dart';
import 'package:calmera/presentation/widgets/chat/typing_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;


  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final history = await ChatService.getConversation();
    setState(() {
      _messages.addAll(history);

    });

  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      isTyping = true;
    });
    _controller.clear();


    final botResponse = await ChatService.sendMessage(text);

    setState(() {
      _messages.add({'text': botResponse, 'isUser': false});
      isTyping = false;
    });

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C8955),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('img/avatar.jpg'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Психолог', style: GoogleFonts.nunitoSans(fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,)),
                    Text('• Онлайн', style: GoogleFonts.nunitoSans(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,)),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFFFDFCF9),
        child:
            Stack(
              children: [
                ListView.builder(
                    physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: _messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isTyping) {
                        if(index == 0) {
                          return const TypingIndicator();
                        }
                        else {
                          final msg = _messages[_messages.length - index];
                          return ChatBubble(
                            text: msg['text'],
                            isUser: msg['isUser'],
                          );
                        }
                      } else {
                        final msg = _messages[_messages.length - 1 - index];
                        return ChatBubble(
                          text: msg['text'],
                          isUser: msg['isUser'],
                        );
                      }
                    }
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ChatInputField(
                    controller: _controller,
                    onSend: _sendMessage,
                  ),
                ),
              ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2,),
    );
  }
}












