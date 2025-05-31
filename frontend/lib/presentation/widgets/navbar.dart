import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../catalog.dart';
import '../chat.dart';
import '../diary.dart';
import '../profile.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ProfilePage(),
      DiaryPage(),
      const ChatPage(),
      const ExercisesPage(),
    ];

    final navItems = [
      _NavItem(Icons.account_circle_outlined, Icons.account_circle, 0),
      _NavItem(Icons.edit_calendar_outlined, Icons.edit_calendar, 1),
      _NavItem(Icons.chat_outlined, Icons.chat_rounded, 2),
      _NavItem(Icons.collections_bookmark_outlined, Icons.collections_bookmark, 3),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...navItems.map((item) => _buildNavButton(
                context: context,
                icon: currentIndex == item.index ? item.activeIcon : item.inactiveIcon,
                isActive: currentIndex == item.index,
                onTap: () {
                  if (currentIndex != item.index) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => pages[item.index],
                        transitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              )),
              _buildNavButton(
                context: context,
                icon: Icons.phone_in_talk,
                isActive: true,
                isEmergency: true,
                onTap: () {
                  _showEmergencyCallDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    bool isEmergency = false,
    required VoidCallback onTap,
  }) {
    final Color activeColor = const Color(0xFF2C8955);
    final Color inactiveColor = const Color(0xFFB2AEAE);
    final Color emergencyColor = Colors.red;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 30,
          color: isEmergency ? emergencyColor : (isActive ? activeColor : inactiveColor),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final int index;

  _NavItem(this.inactiveIcon, this.activeIcon, this.index);
}

void _showEmergencyCallDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Звонок в службу доверия'),
        content: Text('Хотите позвонить в бесплатную кризисную линию доверия по России?'),
        actions: <Widget>[
          TextButton(
            child: Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Позвонить'),
            onPressed: () {
              Navigator.of(context).pop();
              _makeEmergencyCall();
            },
          ),
        ],
      );
    },
  );
}

void _makeEmergencyCall() async {
  const phoneNumber = 'tel:+78003334434';
  if (await canLaunch(phoneNumber)) {
    await launch(phoneNumber);
  } else {
    throw 'Не удалось совершить звонок.';
  }
}