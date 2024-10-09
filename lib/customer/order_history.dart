import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/customer/edit_profile.dart';
import 'package:bgm/models/order.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<HistoryTile> orderHistory = [];
  double rating = 1;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  getOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(
        APIRoutes.getOrderHistory,
      ),
      body: {
        "userID": prefs.getString("id")!,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        orderHistory = jsonResponse['orderHistory']
            .map<HistoryTile>((item) => HistoryTile.fromJson(item))
            .toList();
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
                      child: Padding(
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
                                'Status: ${orderHistory[index].status}',
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
                              if (orderHistory[index].status == "delivered")
                                Divider(
                                  color: AppConst.secondaryColor,
                                ),
                              if (orderHistory[index].status == "delivered" &&
                                  orderHistory[index].rating == "no")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rate your experience',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: 1,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      tapOnlyMode: true,
                                      onRatingUpdate: (score) {
                                        setState(() {
                                          rating = score;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Rating order, please wait...");
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        var response = await http.post(
                                          Uri.parse(
                                            APIRoutes.rateVendor,
                                          ),
                                          body: {
                                            "orderID": orderHistory[index].id,
                                            "vendorID":
                                                orderHistory[index].vendorID,
                                            "userID": prefs.getString("id")!,
                                            "rate": rating.toString(),
                                          },
                                        );
                                        var jsonResponse =
                                            jsonDecode(response.body);
                                        print(jsonResponse);
                                        if (jsonResponse['status'] == 200) {
                                          setState(() {
                                            orderHistory[index].rating =
                                                rating.toString();
                                          });
                                          Fluttertoast.showToast(
                                            msg:
                                                "Ratings added to vendor successfully",
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppConst.secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Submit',
                                            style: GoogleFonts.dmSans(
                                              color: AppConst.accentColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (orderHistory[index].status == "delivered" &&
                                  orderHistory[index].rating != "no")
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ratings:",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(3.0, 3.0),
                                            blurRadius: 3.0,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Icon(Icons.star, color: Colors.yellow),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " ${orderHistory[index].rating}",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(3.0, 3.0),
                                            blurRadius: 3.0,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                            ],
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
