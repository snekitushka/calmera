import 'package:calmera/presentation/widgets/chat/chat_input_field.dart';
import 'package:calmera/presentation/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../services/chat_service.dart';
import '../text_styles.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatVideoPage extends StatefulWidget {
  final void Function(String) onSend;

  const ChatVideoPage({
    required this.onSend,
    super.key,
  });

  @override
  State<ChatVideoPage> createState() => _ChatVideoPageState();
}

class _ChatVideoPageState extends State<ChatVideoPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  late VideoPlayerController _controllerVideo;
  late Future<void> _initializeVideoPlayerFuture;



  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';


  @override
  void initState() {
    super.initState();
    _loadConversation();
    _controllerVideo = VideoPlayerController.networkUrl(
        Uri.parse("https://res.cloudinary.com/dpq5mqnbe/video/upload/v1748029169/i6jxaqemazwav3acokr1.mp4"));
    _initializeVideoPlayerFuture = _controllerVideo.initialize().then((_) {
      setState(() {});
      _controllerVideo.play();
    });
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();

    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      setState(() {
        _controller.clear();
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _controller.text = _lastWords;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerVideo.dispose();
  }

  Future<void> _loadConversation() async {
    final history = await ChatService.getConversation();
    setState(() {
      _messages.addAll(history);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final botResponse = await ChatService.sendMessage(text);

    setState(() {
      _messages.add({'text': botResponse, 'isUser': false});
      isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final String videoUrl = "https://res.cloudinary.com/dpq5mqnbe/video/upload/v1748029169/i6jxaqemazwav3acokr1.mp4";

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text('Психолог', style: TextStyles.title),
         SizedBox(height: 60,),
         FutureBuilder<void>(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Ошибка загрузки видео');
            } else {
              return AspectRatio(
                aspectRatio: _controllerVideo.value.aspectRatio,
                child: VideoPlayer(_controllerVideo),
              );
            }
          },
        ),
            SizedBox(
              height: 30,
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.red,
              child: IconButton(onPressed: () {
                Navigator.pop(context);
              },
                  icon: Icon(Icons.call_end_rounded, color: Colors.white)),
            )
    ]),
    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2C8955),
        onPressed:
        // If not yet listening for speech start, otherwise stop
        _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, color: Colors.white,),
      ),
    );
  }
}









