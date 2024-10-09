import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bgm/constants/constants.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool hasAgreed = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<String> allergens = [];

  bool isProcessing = false;

  static List<String> _allergens = [
    "Milk",
    "Eggs",
    "Fish",
    "Crustaceans",
    "Tree nuts",
    "Peanuts",
    "Wheat",
    "Soybeans",
    "Celery",
    "Mustard",
    "Sesame",
    "Sulphites",
    "Lupin",
    "Molluscs",
    "None",
  ];
  final _items = _allergens
      .map((allerg) => MultiSelectItem<String>(allerg, allerg))
      .toList();

  signup() async {
    if (nameController.text.isEmpty || nameController.text.length < 3 && nameController.text.length > 28) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          content: Text("Please enter a valid name",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }

    if (emailController.text.isEmpty || !emailController.text.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          content: Text("Please enter a valid email",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }

    if (emailController.text.contains("@bagm.com")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          content: Text(
            "Please refrain from using @bagm.com email addresses for Customer Accounts",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
          ),
        ),
      );
      return;
    }

    if (cityController.text.isEmpty || cityController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //backgroundColor: AppConst.accentColor,
          backgroundColor: Colors.deepOrangeAccent,
          content: Text("Please enter a valid delivery city",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }
    if (countryController.text.isEmpty || countryController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //backgroundColor: AppConst.accentColor,
          backgroundColor: Colors.deepOrangeAccent,
          content: Text("Please enter a valid delivery country",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }
    if (!RegExp(r'^[0-9]{11,13}$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please enter a valid phone number with 11 to 13 digits starting with 0",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
          ),
        ),
      );
      return;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppConst.accentColor,
          content:
              Text("Please enter a valid password with atleast 6 characters"),
        ),
      );
      return;
    }

    if (!hasAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //backgroundColor: AppConst.accentColor,
          backgroundColor: Colors.red,
          content: Text("Please agree to the terms and conditions",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }
    setState(() {
      isProcessing = true;
    });
    final response = await http.post(
      Uri.parse(APIRoutes.signup),
      body: {
        'name': nameController.text,
        'allergens': allergens
            .toString()
            .replaceAll("[", "")
            .replaceAll("]", "")
            .replaceAll(" ", "")
            .replaceAll("'", ""),
        'password': passwordController.text,
        'email': emailController.text,
      },
    );
    print({
      'name': nameController.text,
      'allergens': allergens
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(" ", "")
          .replaceAll("'", ""),
      'password': passwordController.text,
      'email': emailController.text,
      'city': cityController.text,
      'country': countryController.text,
      'phone': phoneController.text,
    });
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    setState(() {
      isProcessing = false;
    });
    Fluttertoast.showToast(
      msg: jsonResponse['message'],
    );
    if (jsonResponse['status'] == 200) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(jsonResponse['message'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              //image: DecorationImage(
               // image: AssetImage('assets/bg.png'),
               // fit: BoxFit.cover,
              ),
            ),
         // ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    "Signup",
                    style: GoogleFonts.dmSans(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: <Shadow>[
                        Shadow(
                           offset: Offset(1.0, 2.0),
                                      blurRadius: 0.5,
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
                        "Name:",
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
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      filled: true,
                      fillColor: AppConst.primaryColor,
                      // errorText: nameController.text.isEmpty ? "Name cannot be empty" : null,
                    ),
                  ),
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
                ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone:",
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
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      filled: true,
                      fillColor: AppConst.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "City:",
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
                    controller: cityController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      filled: true,
                      fillColor: AppConst.primaryColor,
                    ),
                  ),
                ),
  ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Country:",
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
                    controller: countryController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      filled: true,
                      fillColor: AppConst.primaryColor,
                    ),
                  ),
                ),

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
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    // height: 100,
                    decoration: BoxDecoration(
                      color: AppConst.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          MultiSelectBottomSheetField(
                            initialChildSize: 0.4,
                            maxChildSize: 0.8,
                            listType: MultiSelectListType.CHIP,
                            searchable: true,
                            buttonText: Text(
                              "Select your Allergens",
                              style: GoogleFonts.dmSans(
                                color: Colors.black,
                              ),
                            ),
                            title: Text(
                              "Allergens",
                              style: GoogleFonts.dmSans(
                                color: Colors.black,
                              ),
                            ),
                            items: _items,
                            onConfirm: (values) {
                              setState(() {
                                allergens = [];
                              });
                              values.forEach((element) {
                                setState(() {
                                  allergens.add(
                                    element.toString(),
                                  );
                                });
                              });
                            },
                            chipDisplay: MultiSelectChipDisplay(
                              // height: 100,
                              scroll: true,
                              textStyle: GoogleFonts.dmSans(
                                color: Colors.black,
                              ),
                              onTap: (value) {
                                setState(() {
                                  allergens.remove(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Row(
                    children: [
                      Checkbox(
                        side: BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                        value: hasAgreed,
                        onChanged: (value) {
                          setState(() {
                            hasAgreed = value!;
                          });
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "TERMS & CONDITIONS",
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
                    ],
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "You agree to use this app safely for it's intended purpose.",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
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
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (isProcessing)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isProcessing = false;
                      });
                    },
                    child: CircularProgressIndicator(
                      color: AppConst.accentColor,
                    ),
                  ),
                if (!isProcessing)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        signup();
                      },
                      child: Text(
                        "REGISTER",
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
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "< Back to login",
                      style: GoogleFonts.dmSans(
                        fontSize: 25,
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
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
