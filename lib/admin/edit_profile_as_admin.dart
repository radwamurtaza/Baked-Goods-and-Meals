import 'dart:convert';

import 'package:bgm/admin/admin_dashboard.dart';
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

class AdminEditProfile extends StatefulWidget {
  String id;

  AdminEditProfile({required this.id});
  @override
  State<AdminEditProfile> createState() => _AdminEditProfileState();
}

class _AdminEditProfileState extends State<AdminEditProfile> {
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
    var response = await http.get(
      Uri.parse(
        APIRoutes.getUser + "?id=${widget.id}",
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(),
      ),
      (route) => false,
    );
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
                              'Edit Profile as Admin',
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
                    height: 40,
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
                                offset: Offset(1.0, 2.0),
                                      blurRadius: 0.5,
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
                                 offset: Offset(1.0, 2.0),
                                      blurRadius: 0.5,
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
                          "Address:",
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
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
                  if (!isBanned)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            var response = await http.post(
                              Uri.parse(APIRoutes.banUser),
                              body: {
                                "id": widget.id,
                              },
                            );
                            var jsonResponse = jsonDecode(response.body);

                            if (jsonResponse['status'] == 200) {
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
                            }
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
                                     offset: Offset(1.0, 2.0),
                                      blurRadius: 0.5,
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
                  if (isBanned)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            var response = await http.post(
                              Uri.parse(APIRoutes.unbanUser),
                              body: {
                                "id": widget.id,
                              },
                            );
                            var jsonResponse = jsonDecode(response.body);

                            if (jsonResponse['status'] == 200) {
                              setState(() {
                                isBanned = false;
                              });
                              Fluttertoast.showToast(
                                msg: "User unbanned Successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
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
                                     offset: Offset(1.0, 2.0),
                                      blurRadius: 0.5,
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
