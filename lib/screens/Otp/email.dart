import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({Key? key}) : super(key: key);

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  bool isButtonDisabled = false;
  late TextEditingController _emailController;
  Timer? timer;
  Completer<void>? _completer;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: FirebaseAuth.instance.currentUser!.email);

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    timer?.cancel();
    _completer?.complete();
    super.dispose();
  }

  Future<void> _delayedTask() async {
    _completer = Completer<void>();
    await Future.delayed(const Duration(seconds: 30), () {
      if (!_completer!.isCompleted) {
        setState(() {
          isButtonDisabled = false;
        });
        _completer!.complete();
      }
    });
    return _completer!.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/img1.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Email Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Please verify your email address to continue",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonDisabled
                          ? Colors.grey
                          : Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isButtonDisabled
                        ? null
                        : () async {
                            try {
                              setState(() {
                                isButtonDisabled = true;
                              });
                              final user = FirebaseAuth.instance.currentUser!;
                              if (!user.emailVerified) {
                                await user.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Verification email sent"),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Error sending verification email: $e"),
                                ),
                              );
                            }
                            await _delayedTask();
                          },
                    child: const Text("Send")),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                child: const Text(
                  'Maybe later',
                  style: TextStyle(
                    color: Color(0xFF5B5B5B),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
