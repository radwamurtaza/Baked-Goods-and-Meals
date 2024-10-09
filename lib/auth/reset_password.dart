import 'dart:convert';
import 'package:bgm/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/auth/login.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  String otp;
  String email;

  ResetPasswordScreen({required this.otp, required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool otpVerified = false;

  bool isLoading = false;

  void verifyOtp(String enteredOtp) {
    setState(() {
      otpVerified = (enteredOtp == widget.otp);
      if (otpVerified) {
        Fluttertoast.showToast(
          msg: "OTP verified, please enter your new password",
        );
      }
    });
  }

  Future<void> saveNewPassword() async {
    setState(() {
      isLoading = true;
    });
    String newPassword = passwordController.text;
    String confirmedPassword = confirmPasswordController.text;

    if (newPassword.length >= 6) {
      if (newPassword == confirmedPassword) {
        final response = await http.post(
          Uri.parse(APIRoutes.resetPassword),
          body: {
            'email': widget.email,
            'newPassword': newPassword,
          },
        );
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse['status'] == 200) {
          Fluttertoast.showToast(msg: "Password reset successful.");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (route) => false,
          );
        } else {
          Fluttertoast.showToast(msg: "Password reset failed.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Passwords do not match.");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Password should be atleast 6 characters");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    MediaQueryData queryData; //
    queryData = MediaQuery.of(context); //
    double pixels = queryData.devicePixelRatio; //

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(//to avoid pixel problem
          children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            children: [
              SizedBox(height: 30),
              Container(
                width: w,
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  otpVerified
                      ? "Please enter your new password and save."
                      : "Enter the OTP sent to your email address to continue.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter OTP",
                  ),
                  onChanged: verifyOtp,
                  readOnly: otpVerified,
                ),
              ),
              SizedBox(height: 16.0),
              if (otpVerified)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "New Password",
                        ),
                        readOnly: isLoading,
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
                        ),
                        readOnly: isLoading,
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              SizedBox(height: 60),
              if (isLoading)
                Center(
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: CircularProgressIndicator()),
                ),
              if (!isLoading && otpVerified)
                InkWell(
                  onTap: () {
                    saveNewPassword();
                  },
                  child: Container(
                    width: w * 0.5,
                    height: h * 0.08,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 2),
                      color: AppConst.accentColor,
                    ),
                    child: Center(
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Return Back",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: w * 0.2),
            ],
          ),
        ),
      ]),
    );
  }
}
