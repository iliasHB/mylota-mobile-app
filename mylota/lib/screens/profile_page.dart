import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mylota/screens/transactions_page.dart';
import 'package:mylota/widgets/account_delete.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/forget_password_controller.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  File? _image;
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: (snapshot.data!['image'] == null || snapshot.data!['image'] == "")
                                  ? const AssetImage("assets/images/avatar.jpeg") as ImageProvider
                                  : FileImage(File(snapshot.data!['image'])),
                            ),
                            Positioned(
                              right: -10,
                              bottom: -5,
                              child: IconButton(
                                  onPressed: (){
                                    pickAndSaveProfilePicture();
                                  }, icon: const Icon(Icons.camera_enhance)),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          snapshot.data!['email'],
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
                                              Text(snapshot.data!['firstname'],
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
                                              Text(snapshot.data!['lastname'],
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
                                              Text( snapshot.data!['contact'],
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
                                              Text( snapshot.data!['nationality'],
                                                  style: AppStyle.cardfooter),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.home,
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
                                                "Home Address",
                                                style: AppStyle.cardfooter
                                                    .copyWith(
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                              Text( snapshot.data!['address'],
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
                                              Text(snapshot.data!['subscription']['type'],
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
                                              Text(snapshot.data!['subscription']['expiredAt'],
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
                                    onPressed: () {
                                      logout();
                                    },
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

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    // After logout, navigate to login or welcome screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  void _forgetPassword() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";
    ForgetPwdController.resetPwd(
      email: email, //_emailController.text.trim(),
      context: context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,
    );
  }

  void handleSendEmail() async {
    const emailTo = "mylota138@gmail.com";
    const subject = 'Support Request';
    const message = 'Hi, I need assistance with...';
    Uri url = Uri.parse(
        'mailto:$emailTo?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}');
    await launchUrl(url);
  }

  void handleWhatsAppCall() async {
    // Uri whatsAppURL = Uri.parse("whatsapp://send?phone=$whatsAppNum");
    Uri whatsAppURL = Uri.parse("whatsapp://send?phone=");
    if (Platform.isIOS) {
      // for iOS phone only
      await launchUrl(whatsAppURL);
    } else {
      // android , web
      await launchUrl(whatsAppURL);
    }
  }

  Future<void> pickAndSaveProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final filePath = pickedFile.path;
      // final uploadedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Save to the database
      // Upload image to Firebase Storage
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'image': filePath,
      });

      // Update the state
      setState(() {
        _image = File(filePath); // Update the in-memory image file
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> requestPermissions() async {
    await Permission.photos.request();
    await Permission.camera.request();
    await Permission.storage.request();
  }
}
// final storageRef = FirebaseStorage.instance
//     .ref()
//     .child('profile_pictures')
//     .child('${user!.uid}.jpg');
//
// await storageRef.putFile(file);
//
// // Get the download URL
// final downloadUrl = await storageRef.getDownloadURL();

// Save the URL to Firestore under users collection
// await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//   'profilePicture': downloadUrl,
//   'profilePictureUpdatedAt': uploadedAt,
// });
///

// final dbHelper = DatabaseHelper();
// await dbHelper.insertProfilePicture({
// 'userId': userId,
// 'filePath': filePath,
// 'uploadedAt': uploadedAt,
// });