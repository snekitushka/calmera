import 'package:calmera/text_styles.dart';
import 'package:calmera/presentation/exercise_detail.dart';
import 'package:calmera/presentation/widgets/navbar.dart';
import 'package:calmera/services/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/exercise_service.dart';
import 'auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final status = await UserService.isLoggedIn();
    setState(() {
      isAuthenticated = status;
    });
  }

  void _deleteAccount() async {
    await UserService.deleteUser();
    setState(() {
      isAuthenticated = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные успешно удалены')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF2C8955),
          scrolledUnderElevation: 0,
          title: Text('Профиль', style: TextStyles.title,)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isAuthenticated
            ? Center(
              child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red,),
                              onPressed: () => showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: Text('Удаление аккаунта'),
                                      content: Text('Вы уверены, что хотите удалить аккаунт и все свои данные?'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: Text('Отмена'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          child: Text('Удалить'),
                                          onPressed: () async {
                                            Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                builder: (context) => AuthPage(),
                                              ),);
                                            await _deleteAccount;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Запись удалена')),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              ),
                              child: Text('Удалить аккаунт', style: TextStyles.title,),
                            ),
                          ),
                        ],
                      ),
            )
            : Center(
              child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2C8955),),
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => AuthPage(),
                                ),),
                              child: Text('Войти', style: TextStyles.title,),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2C8955),),
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => AuthPage(),
                                ),),
                              child: Text('Регистрация', style: TextStyles.title,),
                            ),
                          ),

                        ],
                      ),
            ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}





