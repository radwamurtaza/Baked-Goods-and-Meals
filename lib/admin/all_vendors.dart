import 'dart:convert';
import 'package:bgm/admin/create_vendor.dart';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/edit_profile.dart';
import 'package:bgm/models/vendor.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllVendors extends StatefulWidget {
  bool isAdmin;

  AllVendors({this.isAdmin = false});

  @override
  State<AllVendors> createState() => _AllVendorsState();
}

class _AllVendorsState extends State<AllVendors> {
  List<Vendor> vendors = [];

  @override
  void initState() {
    super.initState();
    getVendors();
  }

  getVendors() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getAllVendors,
      ),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      jsonResponse['vendors'].forEach((vendor) {
        vendors.add(
          Vendor.fromJson(vendor),
        );
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateVendor(),
            ),
          );
        },
        label: Text(
          "Register New Vendor",
          style: GoogleFonts.dmSans(
            color: AppConst.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(Icons.add_box_outlined, color: AppConst.secondaryColor),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 75,
              color: AppConst.primaryColor,
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
                        'Admin Panel',
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
            Text(
              'All Vendors (${vendors.length.toString()})',
              style: GoogleFonts.dmSans(
                color: AppConst.secondaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('id', vendors[index].id);
                        prefs.setString('name', vendors[index].name);
                        prefs.setString('email', vendors[index].email);
                        prefs.setString('bannerURL', vendors[index].bannerURL);
                        prefs.setBool('isAdmin', true);
                        Provider.of<ShoppingExperience>(context, listen: false)
                            .customerName
                            .value = vendors[index].name;
                        Provider.of<ShoppingExperience>(context, listen: false)
                            .customerEmail
                            .value = vendors[index].email;
                        Provider.of<ShoppingExperience>(context, listen: false)
                            .customerID
                            .value = vendors[index].id;
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => VendorDashboard(),
                          ),
                          (route) => false,
                        );
                        Fluttertoast.showToast(
                          msg:
                              "Logged in as Adminitrator for ${vendors[index].name}.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 16.0,
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: AppConst.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            trailing: Image.asset(
                              "assets/edit_ic.png",
                            ),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                vendors[index].bannerURL,
                              ),
                            ),
                            title: Text(
                              vendors[index].name +
                                  " - " +
                                  vendors[index].status.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                color: AppConst.secondaryColor,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              vendors[index].email,
                              style: GoogleFonts.dmSans(
                                color: AppConst.accentColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
