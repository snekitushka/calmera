import 'package:calmera/presentation/chat.dart';
import 'package:calmera/presentation/widgets/green_button.dart';
import 'package:calmera/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  Future<void> _acceptTerms(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('img/important.png'),),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Условия использования', style: TextStyles.title.copyWith(color: Colors.black),)),
              Text('Calmera — это виртуальный помощник для психологической поддержки.  Он не заменяет профессионального психолога и не является медицинским средством. \n\n Если вы испытываете тяжёлое эмоциональное состояние, тревогу или кризис — обратитесь за помощью к квалифицированным специалистам..',
              textAlign: TextAlign.center, style: TextStyles.body,),
              Padding(padding: EdgeInsets.only(top: 20)),
              GreenButton(text: 'Продолжить', onPressed: () { _acceptTerms(context); },),
              Padding(padding: EdgeInsets.only(top: 20)),
              Text('Нажимая на кнопку продолжить, вы соглашаетесь с условиями использования', style: TextStyles.body.copyWith(fontSize: 13),
                textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}
