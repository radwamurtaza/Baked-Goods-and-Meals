import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/customer/edit_profile.dart';
import 'package:bgm/models/order.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AllVendorOrders extends StatefulWidget {
  const AllVendorOrders({super.key});

  @override
  State<AllVendorOrders> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<AllVendorOrders> {
  List<BGMOrder> orderHistory = [];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  getOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(
        APIRoutes.getVendorOrders,
      ),
      body: {
        "vendorID": prefs.getString("id")!,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        orderHistory = jsonResponse['orders']
            .map<BGMOrder>((item) => BGMOrder.fromJson(item))
            .toList();
      });
    }
  }

  deliverOrder(String id) async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.deliverOrder,
      ),
      body: {
        "orderID": id,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      Fluttertoast.showToast(
        msg: "Order marked delivered.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConst.secondaryColor,
        textColor: AppConst.primaryColor,
        fontSize: 16.0,
      );
      setState(() {
        orderHistory = [];
        getOrders();
      });
    }
  }

  cancelOrder(String id) async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.cancelOrder,
      ),
      body: {
        "orderID": id,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        Fluttertoast.showToast(
          msg: "Order marked cancelled.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConst.secondaryColor,
          textColor: AppConst.primaryColor,
          fontSize: 16.0,
        );
        orderHistory = [];
        getOrders();
      });
    }
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
        ],
      ),
      body: SafeArea(
        child: Column(
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
                        'Order History',
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
              child: ListView.builder(
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppConst.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                '${orderHistory[index].vendorName} - ${DateTime.parse(orderHistory[index].createdAt).day}/${DateTime.parse(orderHistory[index].createdAt).month}/${DateTime.parse(orderHistory[index].createdAt).year}',
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderHistory[index].orderItems,
                                    style: GoogleFonts.dmSans(
                                      color: AppConst.accentColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Divider(
                                    color: AppConst.secondaryColor,
                                  ),
                                  Text(
                                    'Status: ${orderHistory[index].status.toUpperCase()}',
                                    style: GoogleFonts.dmSans(
                                      color: AppConst.secondaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total: Rs.${orderHistory[index].total}',
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
                          if (orderHistory[index].status == "Pending")
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      deliverOrder(orderHistory[index].id);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppConst.secondaryColor,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            "Deliver",
                                            style: GoogleFonts.dmSans(
                                              color: AppConst.primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      cancelOrder(orderHistory[index].id);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            "Cancel Order",
                                            style: GoogleFonts.dmSans(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
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
