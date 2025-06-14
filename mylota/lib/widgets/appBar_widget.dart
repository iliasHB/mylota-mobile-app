import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    // radius: 50,
                    backgroundImage: AssetImage("assets/images/avatar.jpeg"),
                  ));
            }
            return  InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: (snapshot.data!['image'] == null || snapshot.data!['image'] == "")
                      ? const AssetImage("assets/images/avatar.jpeg") as ImageProvider
                      : FileImage(File(snapshot.data!['image'])),
                ),
              ),
            );
          }),
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
