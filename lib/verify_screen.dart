import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyLogin extends StatefulWidget {
  const VerifyLogin(
      {required this.changeStage,
      required this.verificationCode,
      required this.phoneNumber})
      : super();
  final void Function(String, String) changeStage;
  final String verificationCode, phoneNumber;

  @override
  _VerifyLoginState createState() => _VerifyLoginState();
}

class _VerifyLoginState extends State<VerifyLogin> {
  final codeController = TextEditingController();
  String currentText = "";

  void firebaseFire() async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: widget.verificationCode,
              smsCode: codeController.text))
          .then((value) async {
        if (value.user != null) {
          print(value.user?.phoneNumber);
        }
      });
    } catch (e) {
      print('Catch');
    }
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
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
          child: Column(children: [
            const Center(
              child: Text("กรอกรหัสยืนยันที่ได้รับใน SMS ของคุณ",
                  style: TextStyle(
                      fontSize: 16.0, color: Color.fromRGBO(50, 50, 50, 1))),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                textStyle: const TextStyle(color: Colors.white),
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    activeFillColor: const Color.fromARGB(255, 255, 51, 85),
                    inactiveColor: Colors.white,
                    inactiveFillColor: const Color.fromARGB(255, 230, 230, 230),
                    selectedFillColor: const Color.fromARGB(255, 255, 51, 85),
                    selectedColor: Colors.white,
                    activeColor: Colors.white),
                animationDuration: const Duration(milliseconds: 200),
                backgroundColor: Colors.white,
                enableActiveFill: true,
                controller: codeController,
                onCompleted: (v) => firebaseFire,
                onChanged: (value) {
                  setState(() {
                    currentText = value;
                  });
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ),
            )
          ]),
        ));
  }
}
