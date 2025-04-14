import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/main_screen.dart';
import 'package:mylota/screens/register_page.dart';
import 'package:provider/provider.dart';
import '../core/usecase/provider/water_intake_provider.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_decorator.dart';
import 'home_page.dart'; // Import HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // PrefUtils prefUtils = PrefUtils();

  bool isPasswordVisible = true;

  bool isRememberMe = false;

  @override
  void initState() {
    super.initState();
  }


  // void _loadRememberMe() async {
  //   String? rememberedEmail = await prefUtils.getDashStr("rememberMe");
  //   if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
  //     setState(() {
  //       _emailController.text = rememberedEmail;
  //       isRememberMe = true;
  //     });
  //   }
  // }
  //
  // void _toggleRememberMe(bool? value) {
  //   setState(() {
  //     isRememberMe = value ?? false;
  //   });
  //
  //   if (isRememberMe) {
  //     prefUtils.setDashStr("rememberMe", _emailController.text.trim());
  //   } else {
  //     prefUtils.setDashStr("rememberMe", ""); // Clear saved email
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
            // Image.asset(
            //   "assets/images/tematics_name.jpeg",
            //   height: 100,
            // ),
            const SizedBox(height: 40),

            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      cursorColor: Color(0xFF66C3A7),
                      decoration: customInputDecoration(
                          labelText: 'Username or email',
                          hintText: 'abc@gmail.com'),
                      validator: (value) {
                        if (_emailController.text.isEmpty ||
                            _emailController.text == "") {
                          return "Username or email is empty";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: isPasswordVisible,
                      cursorColor: Colors.purple,
                      decoration: customInputDecoration(
                          labelText: 'Password',
                          hintText: '******',
                          prefixIcon:
                              Icon(Icons.lock, color: Color(0xFF2A7F67))),
                      validator: (value) {
                        if (_passwordController.text.isEmpty ||
                            _passwordController.text == "") {
                          return "Password is empty";
                        }
                        return null;
                      },
                    ),
                  ],
                )),
            // Username/Email Field

            const SizedBox(height: 16),

            // Remember me and Forgotten Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isRememberMe,
                      onChanged: null, //_toggleRememberMe,
                      activeColor: Colors.green,
                    ),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, "/forgetPassword"),
                  child: Text(
                    'Forgotten Password?',
                    style: AppStyle.cardfooter
                        .copyWith(fontSize: 14, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CustomContainerLoadingButton()
                : CustomPrimaryButton(
                    label: 'Login',
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        loginUser(_emailController.text.trim(),
                            _passwordController.text.trim());
                        // final loginReqEntity = LoginReqEntity(
                        //     email: _emailController.text.trim(),
                        //     password: _passwordController.text.trim());
                        // context.read<LoginBloc>().add(LoginEvent(loginReqEntity));
                      }
                    },
                  ),

            const SizedBox(height: 20),

            // Terms & Conditions
            Text(
              'By successful login you are agreeing with our Terms & Conditions and Privacy Policy.',
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter
                  .copyWith(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            CustomSecondaryButton(
                label: 'Register',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RegisterPage()))),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    print(email);
    print(password);
    try {
      setState(() {
        isLoading = true;
      });
      // Query Firestore to check if the user exists
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // User exists, proceed with authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() {
          isLoading = false;
        });
        print("User logged in successfully: ${userCredential.user!.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'User does not exist',
          style: AppStyle.cardSubtitle,
        )));

        print("User does not exist");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Error logging in: connection unreachable",
        style: AppStyle.cardSubtitle,
      )));
      print("Error logging in: $e");
    }
  }

}
