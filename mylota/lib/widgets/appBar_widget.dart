import 'package:flutter/material.dart';

import '../screens/profile_page.dart';
import '../utils/styles.dart';

AppBar appBar({required BuildContext context, required String title}) {
  return AppBar(
    title: Text(
      title,
      style: AppStyle.cardTitle,
    ),
    actions: [
      InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            // radius: 50,
            backgroundImage: AssetImage("assets/images/avatar.jpeg"),
          ),
        ),
      ),
      // IconButton(
      //     onPressed: (){
      //       Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
      //     },
      //     icon: const Icon(Icons.settings))
    ],
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)],
        ),
      ),
    ),
    elevation: 5,
  );
}
