import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.changeStage}) : super(key: key);
  final void Function(String, String) changeStage;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  String _verificationCode = "";

  void firebaseFire() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationFailed: (FirebaseAuthException e) {
        },
        codeSent: (String verificationId, int? resendToken) async {
          setState(() {
            _verificationCode = verificationId;
          });
          widget.changeStage('verify', _verificationCode);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("THRIM",
              style: TextStyle(
                  color: Color.fromARGB(255, 204, 0, 61),
                  fontWeight: FontWeight.w900)),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 204, 0, 61)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 204, 0, 61)),
                  ),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 204, 0, 61)),
                  border: UnderlineInputBorder(),
                  labelText: 'กรอกเบอร์โทรศัพท์มือถือของคุณ',
                )),
            Container(
                margin: const EdgeInsets.only(top: 15),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: firebaseFire,
                  style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 218, 32, 63),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('ส่ง SMS เพื่อยืนยัน'),
                ))
          ]),
        ));
  }
}
