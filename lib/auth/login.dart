import 'dart:convert';
import 'package:bgm/auth/forgot_password.dart';
import 'package:bgm/services/shopping_experience.dart';
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hasAgreed = false;
  bool isProcessing = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  login() async {
    if (emailController.text.isEmpty || !emailController.text.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
         // backgroundColor: AppConst.accentColor,
         backgroundColor: Colors.deepOrange,
          content: Text("Please enter a valid email", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
          

        ),
      );
      return;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //backgroundColor: AppConst.accentColor,
           backgroundColor: Colors.deepOrange,
          content: Text("Please enter a valid password",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
        ),
      );
      return;
    }
    if (emailController.text == "bagm@admin.com" &&
        passwordController.text == "bagmadmin") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('id', "bagmadmin");
      prefs.setString('name', "BAGM Admin");
      prefs.setString('email', "bagm@admin.com");
      prefs.setBool('isAdmin', true);
      Provider.of<ShoppingExperience>(context, listen: false)
          .customerName
          .value = "BAGM Admin";
      Provider.of<ShoppingExperience>(context, listen: false)
          .customerEmail
          .value = "bagm@admin.com";
      Provider.of<ShoppingExperience>(context, listen: false).customerID.value =
          "bagmadmin";
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => AdminDashboard(),
        ),
        (route) => false,
      );
      return;
    }
    if (emailController.text.contains(
      "@bagm.com",
    )) {
      setState(() {
        isProcessing = true;
      });
      final response = await http.post(
        Uri.parse(APIRoutes.vendorLogin),
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      setState(() {
        isProcessing = false;
      });
      if (jsonResponse['status'] == 200) {
        if (jsonResponse['account']['status'] == "active") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('id', jsonResponse['account']['id']);
          prefs.setString('name', jsonResponse['account']['name']);
          prefs.setString('email', jsonResponse['account']['email']);
          prefs.setString('bannerURL', jsonResponse['account']['bannerURL']);
          prefs.setBool('isAdmin', false);
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerName
              .value = jsonResponse['account']['name'];
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerEmail
              .value = jsonResponse['account']['email'];
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerID
              .value = jsonResponse['account']['id'];
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => VendorDashboard(),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Your account is banned. Please contact admin.",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(jsonResponse['message']),
          ),
        );
      }
    } else {
      setState(() {
        isProcessing = true;
      });
      final response = await http.post(
        Uri.parse(APIRoutes.login),
        body: {
          'password': passwordController.text,
          'email': emailController.text,
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      setState(() {
        isProcessing = false;
      });
      if (jsonResponse['status'] == 200) {
        if (jsonResponse['account']['status'] == "active") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('id', jsonResponse['account']['id']);
          prefs.setString('name', jsonResponse['account']['name']);
          prefs.setString('email', jsonResponse['account']['email']);
          prefs.setBool('isAdmin', false);
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerName
              .value = jsonResponse['account']['name'];
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerEmail
              .value = jsonResponse['account']['email'];
          Provider.of<ShoppingExperience>(context, listen: false)
              .customerID
              .value = jsonResponse['account']['id'];
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => HomePage(),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Your account is banned. Please contact admin.",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text(jsonResponse['message']),
          ),
        );
      }
    }
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white60,
          image: DecorationImage(
            image: AssetImage(''),
            fit: BoxFit.cover,
          ),
        ),
       
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Center(
              child: Text(
                "Baked\nGoods\n&\nMeals",
                style: GoogleFonts.dmSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ListTile(
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password:",
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
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  filled: true,
                  fillColor: AppConst.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConst.secondaryColor,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(3.0, 3.0),
                        blurRadius: 3.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isProcessing)
              CircularProgressIndicator(
                color: AppConst.accentColor,
              ),
            if (!isProcessing)
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  //SizedBox(height: 20,),
                  child: Text(
                    "Login",
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 2.0),
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
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => SignupScreen(),
                    ),
                  );
                },
              
                child: Text(
                  "Don't have an account? SIGNUP",
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConst.secondaryColor,
                    decoration: TextDecoration.underline,
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
            SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//          color: Colors.white60,
//           image: DecorationImage(
//             image: AssetImage(''),
//             fit: BoxFit.cover,
//           ),
//         ),

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 60),
//             Center(
//               child: Text(
//                 "Baked\nGoods\n&\nMeals",
//                 style: GoogleFonts.dmSans(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                   shadows: <Shadow>[
//                     Shadow(
//                       offset: Offset(3.0, 3.0),
//                       blurRadius: 3.0,
//                       color: Colors.white,
//                     ),
//                   ],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             ListTile(
//               leading: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.3,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Email:",
//                     style: GoogleFonts.dmSans(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       shadows: <Shadow>[
//                         Shadow(
//                           offset: Offset(3.0, 3.0),
//                           blurRadius: 3.0,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               title: TextField(
//                 controller: emailController,
                
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
                    
                   
//                   ),
//                   isDense: true,
//                   contentPadding: EdgeInsets.all(8),
//                   filled: true,
//                   fillColor: AppConst.primaryColor,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.3,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Password:",
//                     style: GoogleFonts.dmSans(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       shadows: <Shadow>[
//                         Shadow(
//                           offset: Offset(3.0, 3.0),
//                           blurRadius: 3.0,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               title: TextField(
//                 obscureText: true,
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   isDense: true,
//                   contentPadding: EdgeInsets.all(8),
//                   filled: true,
//                   fillColor: AppConst.primaryColor,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     CupertinoPageRoute(
//                       builder: (_) => ForgotPasswordScreen(),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   "Forgot your password?       ",
//                   style: GoogleFonts.dmSans(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppConst.secondaryColor,
//                     shadows: <Shadow>[
//                       Shadow(
//                         offset: Offset(3.0, 3.0),
//                         blurRadius: 3.0,
//                         color: Colors.white,
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             if (isProcessing)
//               CircularProgressIndicator(
//                 color: AppConst.accentColor,
//               ),
//             if (!isProcessing)
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.8,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     login();
//                   },
//                   child: Text(
//                     "Login",
//                     style: GoogleFonts.dmSans(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       shadows: <Shadow>[
//                         Shadow(
//                           offset: Offset(1.0, 2.0),
//                           blurRadius: 3.0,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     primary: AppConst.primaryColor,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             SizedBox(
//               height: 50,
//             ),
//             Center(
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     CupertinoPageRoute(
//                       builder: (_) => SignupScreen(),
//                     ),
//                   );
//                 },
                
//                 child: Text(
//                   "Don't have an account? SIGNUP",
                
//                   style:
//                    GoogleFonts.dmSans(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppConst.secondaryColor,
//                     decoration: TextDecoration.underline,
//                     shadows: <Shadow>[
//                       Shadow(
//                         offset: Offset(3.0, 3.0),
//                         blurRadius: 3.0,
//                         color: Colors.white,
//                       ),
//                     ],
                    
//                   ),
      
//                   textAlign: TextAlign.center,
                
                  
//                 ),
//               ),
//             ),
//           ],
//         ),
//         ),
    
//       );
    
//   }
// }
