import 'dart:convert';

import 'package:bgm/admin/admin_dashboard.dart';
import 'package:bgm/auth/login.dart';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:bgm/vendor/all_vendor_orders.dart';
import 'package:bgm/vendor/all_vendor_products.dart';
import 'package:bgm/vendor/vendor_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VendorDashboard extends StatefulWidget {
  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  String ordersCount = "...";
  String productsCount = "...";
  String plansCount = "...";

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    getCounts();
  }

  getCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isAdmin")!) {
      setState(() {
        isAdmin = true;
      });
    }
    var response = await http.post(
      Uri.parse(APIRoutes.getCounts),
      body: {
        "vendorID": prefs.getString("id"),
      },
    );
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == 200) {
      setState(() {
        ordersCount = jsonResponse['orders'].toString();
        productsCount = jsonResponse['products'].toString();
        plansCount = jsonResponse['plans'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isAdmin
          ? Wrap(
              children: [
                Container(
                  height: 60,
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('id', "bagmadmin");
                          prefs.setString('name', "BAGM Admin");
                          prefs.setString('email', "bagm@admin.com");
                          prefs.setBool('isAdmin', true);
                          Provider.of<ShoppingExperience>(context,
                                  listen: false)
                              .customerName
                              .value = "BAGM Admin";
                          Provider.of<ShoppingExperience>(context,
                                  listen: false)
                              .customerEmail
                              .value = "bagm@admin.com";
                          Provider.of<ShoppingExperience>(context,
                                  listen: false)
                              .customerID
                              .value = "bagmadmin";
                          Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AdminDashboard(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Exit Vendor Mode",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 65,
              color: AppConst.primaryColor,
              child: Align(
                alignment: Alignment.center,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Provider.of<ShoppingExperience>(context, listen: true)
                            .customerName
                            .value,
                        style: GoogleFonts.dmSans(
                          color: AppConst.secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAdmin ? "Managing as Admin" : 'Vendor Dashboard',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => AllVendorOrders(),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/orders_ic.png",
                                height: 65,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'All Orders ($ordersCount)',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => AllVendorProducts(
                              isProduct: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/milk_ic.png",
                                height: 65,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'All Products ($productsCount)',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => AllVendorProducts(
                              isProduct: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/grocery_ic.png",
                                height: 65,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'All Plans ($plansCount)',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => VendorSettings(),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.profile_circled,
                                    size: 60,
                                    color: Colors.brown,
                                  ),
                                  Icon(
                                    CupertinoIcons.star_fill,
                                    size: 45,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Profile & Reviews',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.logout,
                                size: 60,
                                color: Colors.red,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Logout',
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
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
