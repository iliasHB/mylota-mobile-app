import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylota/screens/transactions_page.dart';
import 'package:mylota/widgets/account_delete.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/forget_password_controller.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;

  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: AppStyle.cardTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(
                        child: Text(
                          "No user found",
                          style: AppStyle.cardSubtitle,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        const Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage("assets/images/avatar.jpeg"),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Icon(Icons.camera_enhance),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'soliuhabeeb@gmail.com',
                          style: AppStyle.cardSubtitle,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: CustomSecondaryButton(
                                    label: '0 | Transactions',
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const Transactions()));
                                    }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Basic Information",
                              style: AppStyle.cardfooter,
                              textAlign: TextAlign.left,
                            )),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Firstname",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("Habeeb",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Lastname",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("Habeeb",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Phone Number",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("09087898767",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Nationality",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("Nigeria",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.queue_play_next,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Subscription Plan",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("Basic",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Plan Expired Period",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Text("Basic",
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              const SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Basic Operations",
                    style: AppStyle.cardfooter,
                    textAlign: TextAlign.left,
                  )),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.password,
                                  color: Colors.green[500],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Change Password",
                                      style: AppStyle.cardfooter.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text("42", style: AppStyle.cardfooter),
                                  ],
                                ),
                                const Spacer(),
                                isLoading
                                    ? const CustomContainerLoadingButton()
                                    : IconButton(
                                        onPressed: () {
                                          _forgetPassword();
                                        },
                                        icon: const Icon(Icons.arrow_right_alt))
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.green[500],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Logout",
                                      style: AppStyle.cardfooter.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text("42", style: AppStyle.cardfooter),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.arrow_right_alt))
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Colors.green[500],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Share",
                                      style: AppStyle.cardfooter.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text("42", style: AppStyle.cardfooter),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () {
                                      handleWhatsAppCall();
                                    },
                                    icon: const Icon(Icons.arrow_right_alt))
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Icon(
                                  Icons.support_agent,
                                  color: Colors.green[500],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Support",
                                      style: AppStyle.cardfooter.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text("42", style: AppStyle.cardfooter),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () {
                                      handleSendEmail();
                                    },
                                    icon: const Icon(Icons.arrow_right_alt))
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.green[500],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Account Delete",
                                      style: AppStyle.cardfooter.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text("42", style: AppStyle.cardfooter),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AccountDelete()));
                                    },
                                    icon: const Icon(Icons.arrow_right_alt))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _forgetPassword() {
    ForgetPwdController.resetPwd(
      email: "", //_emailController.text.trim(),
      context: context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,
    );
  }

  void handleSendEmail() async {
    final emailTo = "mylota138@gmail.com";
    final subject = 'Support Request';
    final message = 'Hi, I need assistance with...';
    Uri url = Uri.parse(
        'mailto:$emailTo?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}');
    await launchUrl(url);
  }

  void handleWhatsAppCall() async {
    // Uri whatsAppURL = Uri.parse("whatsapp://send?phone=$whatsAppNum");
    Uri whatsAppURL = Uri.parse("whatsapp://send");
    if (Platform.isIOS) {
      // for iOS phone only
      await launchUrl(whatsAppURL);
    } else {
      // android , web
      await launchUrl(whatsAppURL);
    }
  }

  // Future<void> pickAndSaveProfilePicture(int userId) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     final filePath = pickedFile.path;
  //     final uploadedAt =
  //     DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  //
  //     print('userId: $userId');
  //
  //     // Save to the database
  //     final dbHelper = DatabaseHelper();
  //     await dbHelper.insertProfilePicture({
  //       'userId': userId,
  //       'filePath': filePath,
  //       'uploadedAt': uploadedAt,
  //     });
  //
  //     print('Profile picture saved: $filePath');
  //     // Update the state
  //     setState(() {
  //       _image = File(filePath); // Update the in-memory image file
  //     });
  //   } else {
  //     print('No image selected.');
  //   }
  // }
}
