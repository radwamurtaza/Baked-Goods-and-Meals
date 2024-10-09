import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/models/user.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  bool isAdmin;

  EditProfile({this.isAdmin = false});

  @override
  State<EditProfile> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<EditProfile> {
  bool isBanned = false;

  BGMUser? user;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController allergenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.get(
      Uri.parse(
        APIRoutes.getUser + "?id=${prefs.getString('id')!}",
      ),
    );
    var jsonResponse = jsonDecode(response.body);
    setState(() {
      user = BGMUser.fromJson(jsonResponse['user']);
      nameController.text = user!.name;
      phoneController.text = user!.phone;
      addressController.text = user!.address;
      allergenController.text = user!.allergens;
    });
  }

  saveDetails() async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.updateProfile,
      ),
      body: {
        'userID': user!.id,
        'email': user!.email,
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'allergens': allergenController.text,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    Fluttertoast.showToast(
      msg: jsonResponse['message'],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    Provider.of<ShoppingExperience>(context, listen: false).customerName.value =
        nameController.text;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConst.accentColor,
      bottomNavigationBar: Wrap(
        children: [
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/home_ic.png",
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isAdmin)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => CartPage(),
                  ),
                );
              },
              child: Container(
                height: 60,
                color: AppConst.accentColor,
                child: ListTile(
                  leading: Badge(
                    backgroundColor: AppConst.secondaryColor,
                    label: Text(
                      Provider.of<ShoppingExperience>(context, listen: true)
                          .cartItems
                          .value
                          .length
                          .toString(),
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Image.asset(
                      "assets/cart_ic.png",
                      height: 30,
                    ),
                  ),
                  trailing: Text(
                    "Cart",
                    style: GoogleFonts.dmSans(
                      color: AppConst.secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
                children: [
                  Container(
                    height: 75,
                    color: AppConst.accentColor,
                    child: Align(
                      alignment: Alignment.center,
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/back_ic.png",
                                ),
                              ),
                            ),
                            Text(
                              widget.isAdmin
                                  ? 'Edit Profile as Admin'
                                  : 'Edit Profile',
                              style: GoogleFonts.dmSans(
                                color: AppConst.secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                            // shadows: <Shadow>[
                            //   Shadow(
                            //     offset: Offset(3.0, 3.0),
                            //     blurRadius: 3.0,
                            //     color: Colors.white,
                            //   ),
                            // ],
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
                            // shadows: <Shadow>[
                            //   Shadow(
                            //     offset: Offset(3.0, 3.0),
                            //     blurRadius: 3.0,
                            //     color: Colors.white,
                            //   ),
                            // ],
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
                          "Address:",
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            // shadows: <Shadow>[
                            //   Shadow(
                            //     offset: Offset(3.0, 3.0),
                            //     blurRadius: 3.0,
                            //     color: Colors.white,
                            //   ),
                            // ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    title: TextField(
                      controller: addressController,
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
                          "Allergen:",
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            // shadows: <Shadow>[
                            //   Shadow(
                            //     offset: Offset(3.0, 3.0),
                            //     blurRadius: 3.0,
                            //     color: Colors.white,
                            //   ),
                            // ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    title: TextField(
                      controller: allergenController,
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
                    height: 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        saveDetails();
                      },
                      child: Text(
                        "SAVE",
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          // shadows: <Shadow>[
                          //   Shadow(
                          //     offset: Offset(3.0, 3.0),
                          //     blurRadius: 3.0,
                          //     color: Colors.white,
                          //   ),
                          // ],
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
                  if (!isBanned && widget.isAdmin)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isBanned = true;
                            });
                            Fluttertoast.showToast(
                              msg: "User Banned Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "Ban User",
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 3.0,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isBanned && widget.isAdmin)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isBanned = false;
                            });
                            Fluttertoast.showToast(
                              msg: "User Unbanned Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "Unban User",
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 3.0,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
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
