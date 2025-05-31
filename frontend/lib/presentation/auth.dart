import 'package:calmera/presentation/widgets/green_button.dart';
import 'package:calmera/presentation/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../text_styles.dart';
import 'chat.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLogin = false;

  void _submit() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    final success = isLogin
        ? await UserService.loginUser(username, password)
        : await UserService.registerUser(username, password);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin ? 'Ошибка авторизации' : 'Ошибка регистрации'),
        ),
      );
    }
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLogin ? 'Вход' : 'Регистрация', style: TextStyles.title.copyWith(color: Colors.black),),
            SizedBox(height: 20,),
            InputField(
              label: 'Имя',
              controller: usernameCtrl,
            ),
            SizedBox(height: 10,),
            InputField(
              label: 'Пароль',
              controller: passwordCtrl,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            GreenButton(text: isLogin ? 'Войти' : 'Зарегистрироваться', onPressed: _submit),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _toggleMode,
              child: Text(
                isLogin
                    ? 'Нет аккаунта? Зарегистрироваться'
                    : 'Уже есть аккаунт? Войти',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}