import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';
import 'package:mylota/utils/styles.dart';

import '../controller/forget_password_controller.dart';
import '../controller/login_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_decorator.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _forgetPassword() {
    ForgetPwdController.resetPwd(
      email: _emailController.text.trim(),
      context: context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,
    );
  }

  // Future<void> _forgetPassword() async {
  //   try {
  //     await FirebaseAuth.instance
  //         .sendPasswordResetEmail(email: _emailController.text.trim());
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Password reset email sent')),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message ?? 'An error occurred')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Path to your logo
                  width: 60,
                  height: 60,
                ),
                Text(
                  'MyLota',
                  style: AppStyle.cardTitle,
                ),
              ],
            ),
            const SizedBox(height: 40),

            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      cursorColor: const Color(0xFF66C3A7),
                      decoration: customInputDecoration(
                          labelText: 'Email', hintText: 'abc@gmail.com'),
                      validator: (value) {
                        if (_emailController.text.isEmpty ||
                            _emailController.text == "") {
                          return "Email is empty";
                        }
                        return null;
                      },
                    ),
                  ],
                )),

            const SizedBox(height: 20),
            isLoading
                ? const CustomContainerLoadingButton()
                : CustomPrimaryButton(
                    label: 'Continue',
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _forgetPassword();
                        // LoginController.loginUser(_emailController.text.trim(),
                        //     _passwordController.text.trim());
                      }
                    },
                  ),

            const SizedBox(height: 20),

            // Terms & Conditions
            Text(
              'Password reset link will be sent to the email you provided',
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter
                  .copyWith(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            CustomSecondaryButton(
                label: 'Back to Login', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
