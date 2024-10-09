import 'dart:convert';
import 'dart:math';
import 'package:bgm/auth/reset_password.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/admin/admin_dashboard.dart';
import 'package:bgm/auth/signup.dart';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/home_page.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool hasAgreed = false;
  bool isProcessing = false;
  TextEditingController emailController = TextEditingController();

  reset() async {
    Random random = new Random();
    int randomNumber = random.nextInt(900000) + 100000;

    setState(() {
      isProcessing = true;
    });
    final response = await http.post(
      Uri.parse(APIRoutes.forgotPassword),
      body: {
        'email': emailController.text,
        'code': randomNumber.toString(),
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    setState(() {
      isProcessing = false;
    });
    if (jsonResponse['status'] == 200) {
      Fluttertoast.showToast(
        msg:
            "A reset code has been sent to ${emailController.text}. Please enter it to proceed with the password reset process",
      );
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: emailController.text,
            otp: randomNumber.toString(),
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(jsonResponse['message']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          //image: DecorationImage(
            //image: AssetImage('assets/bg.png'),
            //fit: BoxFit.cover,
          //),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Forgot your\npassword?",
                style: GoogleFonts.dmSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(3.0, 3.0),
                      blurRadius: 3.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email:",
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(3.0, 3.0),
                          blurRadius: 3.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              title: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  filled: true,
                  fillColor: AppConst.primaryColor,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (isProcessing)
              CircularProgressIndicator(
                color: AppConst.accentColor,
              ),
            if (!isProcessing)
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    reset();
                  },
                  child: Text(
                    "Reset",
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(3.0, 3.0),
                          blurRadius: 3.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: AppConst.primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
