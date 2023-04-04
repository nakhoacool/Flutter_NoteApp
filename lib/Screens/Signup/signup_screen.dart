import 'package:flutter/material.dart';
import '/constants.dart';
import '/responsive.dart';
import '../../components/background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Background(
        child: SingleChildScrollView(
          reverse: true,
          child: Responsive(
            mobile: const MobileSignupScreen(),
            desktop: Row(
              children: [
                const Expanded(
                  child: SignUpScreenTopImage(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 450,
                        child: SignUpForm(),
                      ),
                      SizedBox(height: defaultPadding / 2),
                      // SocalSignUp()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SignUpScreenTopImage(),
        Row(
          children: const [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom)),
      ],
    );
  }
}
