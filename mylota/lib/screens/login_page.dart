import 'package:flutter/material.dart';
import 'package:mylota/screens/forget_password_page.dart';
import 'package:mylota/screens/register_page.dart';
import 'package:mylota/utils/pref_util.dart';
import '../controller/login_controller.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_decorator.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);

  bool isPasswordVisible = true;

  bool isRememberMe = false;

  PrefUtils prefUtils = PrefUtils();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadRememberMe() async {
    String? rememberedEmail = await prefUtils.getStr("rememberMe");
    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = rememberedEmail;
        isRememberMe = true;
      });
    }
  }

  void _toggleRememberMe(bool? value) {
    setState(() {
      isRememberMe = value ?? false;
    });

    if (isRememberMe) {
      prefUtils.setStr("rememberMe", _emailController.text.trim());
    } else {
      prefUtils.setStr("rememberMe", ""); // Clear saved email
    }
  }

  void _login() {
    LoginController.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,
    );
  }

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
                      onChanged: _toggleRememberMe,
                      activeColor: Colors.green,
                    ),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgetPasswordPage())),
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
                        _login();
                        // LoginController.loginUser(_emailController.text.trim(),
                        //     _passwordController.text.trim());
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
}
