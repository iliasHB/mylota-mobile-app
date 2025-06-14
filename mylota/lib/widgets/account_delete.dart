import 'package:flutter/material.dart';

import '../utils/styles.dart';
import 'custom_button.dart';

class AccountDelete extends StatelessWidget {
  const AccountDelete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 20),
            Text(
              'Account Delete',
              style: AppStyle.cardTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'We are sorry to see you go. Deleting your account is permanent and cannot be undone. '
                  'All your data, including your profile, preferences, and transaction history, will be permanently removed from our system. Are you sure you want to proceed?',
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w200),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      CustomPrimaryButton(label: 'Continue', onPressed: () {}),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: CustomSecondaryButton(
                      label: 'Go Back',
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
