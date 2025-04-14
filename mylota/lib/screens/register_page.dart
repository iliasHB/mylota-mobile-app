import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_decorator.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstnameController = TextEditingController();

  final TextEditingController lastnameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController pwdController = TextEditingController();

  final TextEditingController retypePwdController = TextEditingController();

  final TextEditingController nationalityController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController contactController = TextEditingController();

  String? selectedPlan;
  String? country;
  bool isLoading = false;
  List<String> subscriptionPlans = [];
  List<String> countries = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc("yQtkG0iE0dA0tcrQ8RAW") //3l8kubMtLGsE1kRn9FGN  Change this to your document ID
          .get();

      if (docSnapshot.exists) {
        List<dynamic> data = docSnapshot["Subscription"];
        List<dynamic> nationality = docSnapshot["country"];
        setState(() {
          subscriptionPlans = List<String>.from(data);
          countries = List<String>.from(nationality);
          if (subscriptionPlans.isNotEmpty) {
            // selectedPlan = subscriptionPlans.first; // Default selection
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching dropdown data: ${e.toString()}')));
      print("Error fetching dropdown data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
        child: SingleChildScrollView(
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
              TextField(
                  controller: firstnameController,
                  cursorColor: Colors.green,
                  decoration: customInputDecoration(
                    labelText: 'Firstname',
                    hintText: 'Enter your firstname',
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              TextField(
                  controller: lastnameController,
                  decoration: customInputDecoration(
                    labelText: 'Lastname',
                    hintText: 'Enter your last-name',
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              TextField(
                  controller: contactController,
                  decoration: customInputDecoration(
                    labelText: 'Phone number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.call, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              TextField(
                  controller: emailController,
                  decoration: customInputDecoration(
                    labelText: 'email',
                    hintText: 'abc@gmail.com',
                    // prefixIcon: const Icon(Icons.call, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                  controller: pwdController,
                  obscureText: true,
                  decoration: customInputDecoration(
                    labelText: 'Password',
                    hintText: '*******',
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                  )),
              const SizedBox(height: 16),

              TextFormField(
                  controller: retypePwdController,
                  obscureText: true,
                  decoration: customInputDecoration(
                    labelText: 'confirm password',
                    hintText: '*******',
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                  )),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                  value: country,
                  items: countries.map<DropdownMenuItem<String>>((nation) {
                    return DropdownMenuItem<String>(
                      value: nation,
                      child: Text(
                        nation,
                        style: AppStyle.cardfooter.copyWith(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      country = value;
                    });
                  },
                  decoration: customInputDecoration(
                    labelText: 'Select your nationality',
                    hintText: 'Choose your nationality',
                    prefixIcon: const Icon(Icons.flag, color: Colors.green),
                  )),
              const SizedBox(height: 16),

              TextFormField(
                  controller: addressController,
                  obscureText: true,
                  decoration: customInputDecoration(
                    labelText: 'address',
                    hintText: '10 abc street, state',
                    prefixIcon: const Icon(Icons.home, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              // Subscription Plan Dropdown

              DropdownButtonFormField<String>(
                  value: selectedPlan,
                  items: subscriptionPlans.map<DropdownMenuItem<String>>((lg) {
                    return DropdownMenuItem<String>(
                      value: lg,
                      child: Text(
                        lg,
                        style: AppStyle.cardfooter.copyWith(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlan = value;
                    });
                  },
                  decoration: customInputDecoration(
                    labelText: 'Select a Subscription Plan',
                    hintText: 'Choose a subscription',
                    prefixIcon:
                        const Icon(Icons.warehouse, color: Colors.green),
                  )),
              const SizedBox(height: 16),
              CustomPrimaryButton(
                label: 'Signup',
                onPressed: () {
                  registerUser(
                      emailController.text.trim(),
                      pwdController.text.trim(),
                      firstnameController.text.trim(),
                      lastnameController.text.trim(),
                      selectedPlan,
                      country,
                      addressController.text.trim());
                },
              ),
              SizedBox(height: 20),

              // Back to Login Button
              CustomSecondaryButton(
                  label: 'Back to login',
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => LoginPage())))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(String email, String password, String firstname,
      lastname, subscription, country, address) async {
    try {
      // Check if user already exists in Firebase Authentication
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (methods.isNotEmpty) {
        SnackBar(
          content: Text("User Already exist", style: AppStyle.cardfooter),
        );
        return; // Stop function execution
      }
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
        'subscription': subscription,
        'nationality': country,
        'address': address,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      SnackBar(
        content:
            Text("User registered successfully", style: AppStyle.cardfooter),
      );
      print("User registered successfully");
    } catch (e) {
      SnackBar(
        content: Text("Error registering user: $e", style: AppStyle.cardfooter),
      );
    }
  }
}
