import 'package:calmera/presentation/auth.dart';
import 'package:calmera/presentation/chat.dart';
import 'package:calmera/presentation/chat_video.dart';
import 'package:calmera/presentation/diary.dart';
import 'package:calmera/presentation/profile.dart';
import 'package:calmera/presentation/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final accepted = prefs.getBool('termsAccepted') ?? false;
  runApp(MyApp(termsAccepted: accepted));
}

class MyApp extends StatelessWidget {
  final bool termsAccepted;
  MyApp({required this.termsAccepted});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru'),
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'CalmEra',
        theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x002C8955)),
        useMaterial3: true,
      ),
      home: termsAccepted ? ChatPage() : TermsPage(),
    );
  }
}


