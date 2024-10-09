import 'dart:convert';
import 'package:bgm/admin/all_orders.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/admin/all_customers.dart';
import 'package:bgm/admin/all_vendors.dart';
import 'package:bgm/auth/login.dart';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/vendor/all_vendor_orders.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String ordersCount = "...";
  String usersCount = "...";
  String vendorsCount = "...";

  @override
  void initState() {
    super.initState();
    getCounts();
  }

  getCounts() async {
    var response = await http.post(
      Uri.parse(APIRoutes.getAllCounts),
    );
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == 200) {
      setState(() {
        ordersCount = jsonResponse['orders'].toString();
        vendorsCount = jsonResponse['vendors'].toString();
        usersCount = jsonResponse['users'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Baked Goods & Meals',
                        style: GoogleFonts.dmSans(
                          color: AppConst.secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Dashboard',
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
              height: 100,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AllOrders(),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 140,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/orders_ic.png",
                                  height: 65,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  ' Orders ($ordersCount)',
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AllVendors(
                                isAdmin: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 140,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bakery_dining,
                                  size: 65,
                                  color: Colors.teal,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  ' Vendors ($vendorsCount)',
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
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AllCustomers(),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 140,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.person_2,
                                  size: 65,
                                  color: AppConst.secondaryColor,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  ' Customers ($usersCount)',
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
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 140,
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}
