import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/home_page.dart';
import 'package:bgm/models/order.dart';
import 'package:bgm/models/plan.dart';
import 'package:bgm/models/user.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  TextEditingController deliveryAddressController = TextEditingController();
  BGMUser? user;

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getUser +
            "?id=${Provider.of<ShoppingExperience>(context, listen: false).customerID.value}",
      ),
    );
    var jsonResponse = jsonDecode(response.body);
    setState(() {
      user = BGMUser.fromJson(jsonResponse['user']);
      deliveryAddressController.text = user!.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingExperience>(
        builder: (context, shoppingExperience, _) {
      return Scaffold(
        bottomNavigationBar: isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isProcessing = false;
                        });
                      },
                      child: CircularProgressIndicator(
                        color: AppConst.secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Placing your order...",
                    style: GoogleFonts.dmSans(
                      color: AppConst.secondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : shoppingExperience.cartItems.value.isEmpty
                ? null
                : GestureDetector(
                    onTap: () async {
                      setState(() {
                        isProcessing = true;
                      });
                      String orderItems = "";
                      for (int i = 0;
                          i < shoppingExperience.cartItems.value.length;
                          i++) {
                        orderItems = orderItems +
                            shoppingExperience.cartItems.value[i].productName +
                            " - " +
                            shoppingExperience.cartItems.value[i].title +
                            " x " +
                            shoppingExperience.cartItems.value[i].quantity
                                .toString() +
                            ".\n";
                      }
                      String vendorName = "";
                      var responseV = await http.post(
                        Uri.parse(APIRoutes.getVendor),
                        body: {
                          "vendorID":
                              shoppingExperience.cartItems.value[0].vendorID,
                        },
                      );
                      var jsonResponseV = jsonDecode(responseV.body);
                      // print(jsonResponse);
                      if (jsonResponseV['status'] == 200) {
                        vendorName = jsonResponseV['vendor']['name'];
                        print(vendorName);
                      }
                      var response = await http.post(
                        Uri.parse(
                          APIRoutes.placeOrder,
                        ),
                        body: {
                          "userID": shoppingExperience.customerID.value,
                          "vendorID":
                              shoppingExperience.cartItems.value[0].vendorID,
                          "vendorName": vendorName,
                          "orderItems": orderItems,
                          "userName": shoppingExperience.customerName.value,
                          "userAllergens": user!.allergens,
                          "deliveryAddress": deliveryAddressController.text,
                          "subtotal":
                              shoppingExperience.getSubtotal().toString(),
                          "deliveryCharges": "50",
                          "status": "Pending",
                          "taxes": shoppingExperience.getTax().toString(),
                          "total":
                              shoppingExperience.getTotal().toStringAsFixed(0),
                          "createdAt": DateTime.now().toString(),
                          "updatedAt": DateTime.now().toString(),
                        },
                      );
                      var jsonResponse = jsonDecode(response.body);
                      setState(() {
                        isProcessing = false;
                      });
                      print(jsonResponse);
                      if (jsonResponse['status'] == 200) {
                        shoppingExperience.cartItems.value.clear();

                        Fluttertoast.showToast(
                          msg: "Order Placed Successfully",
                          backgroundColor: Colors.green,
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => HomePage(),
                          ),
                          (route) => false,
                        );
                      } else {
                        Fluttertoast.showToast(msg: jsonResponse['message']);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConst.secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      // color: AppConst.primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Checkout",
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 2.0),
                                    blurRadius: 0.5,
                                    color: AppConst.accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        body: SafeArea(
          child: user == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppConst.accentColor,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Name: ${Provider.of<ShoppingExperience>(context, listen: true).customerName.value}',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: Row(
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/cart_ic.png",
                                height: 30,
                              ),
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              'Your Cart ',
                              style: GoogleFonts.dmSans(
                                color: AppConst.secondaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (shoppingExperience.cartItems.value.isEmpty)
                        Center(
                          child: Text(
                            "Your cart is empty :(",
                            style: GoogleFonts.dmSans(
                              color: AppConst.accentColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: AppConst.secondaryColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: ListView.builder(
                              itemCount:
                                  shoppingExperience.cartItems.value.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 10),
                                  child: Container(
                                    // height: 100,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: AppConst.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppConst.secondaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        MealType _cartItem =
                                                            MealType(
                                                          id: shoppingExperience
                                                              .cartItems
                                                              .value[index]
                                                              .id,
                                                          productID:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .productID,
                                                          productName:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .productName,
                                                          vendorID:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .vendorID,
                                                          title:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .title,
                                                          price:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .price,
                                                          calories:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .calories,
                                                          weight:
                                                              shoppingExperience
                                                                  .cartItems
                                                                  .value[index]
                                                                  .weight,
                                                          quantity: 1,
                                                        );
                                                        shoppingExperience
                                                            .addToCart(
                                                          _cartItem,
                                                        );
                                                      },
                                                      child: Text(
                                                        "+",
                                                        style: GoogleFonts
                                                            .irishGrover(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      shoppingExperience
                                                          .cartItems
                                                          .value[index]
                                                          .quantity
                                                          .toString(),
                                                      style: GoogleFonts
                                                          .irishGrover(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        shoppingExperience
                                                            .removeFromCart(
                                                          shoppingExperience
                                                              .cartItems
                                                              .value[index],
                                                        );
                                                      },
                                                      child: Text(
                                                        "-",
                                                        style: GoogleFonts
                                                            .irishGrover(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              "assets/grocery_ic.png",
                                              width: 50,
                                              height: 50,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Text(
                                                    shoppingExperience
                                                            .cartItems
                                                            .value[index]
                                                            .productName +
                                                        " - " +
                                                        shoppingExperience
                                                            .cartItems
                                                            .value[index]
                                                            .title,
                                                    style: GoogleFonts.dmSans(
                                                      color: AppConst
                                                          .secondaryColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Rs. ${shoppingExperience.cartItems.value[index].price}',
                                                  style: GoogleFonts.dmSans(
                                                    color:
                                                        AppConst.secondaryColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (shoppingExperience.cartItems.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Address',
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: deliveryAddressController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(8),
                                  filled: true,
                                  fillColor: AppConst.primaryColor,
                                ),
                                maxLines: 2,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //   child: ListTile(
                      //     trailing: SizedBox(
                      //       width: MediaQuery.of(context).size.width * 0.2,
                      //       child: Align(
                      //         alignment: Alignment.centerRight,
                      //         child: Text(
                      //           "Apply",
                      //           style: GoogleFonts.dmSans(
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.bold,
                      //             color: AppConst.accentColor,
                      //             shadows: <Shadow>[
                      //               Shadow(
                      //                 offset: Offset(3.0, 3.0),
                      //                 blurRadius: 3.0,
                      //                 color: Colors.white,
                      //               ),
                      //             ],
                      //           ),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //       ),
                      //     ),
                      //     title: TextField(
                      //       decoration: InputDecoration(
                      //         border: OutlineInputBorder(),
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.all(8),
                      //         filled: true,
                      //         fillColor: AppConst.primaryColor,
                      //         hintText: "Enter Coupon Code",
                      //         hintStyle: GoogleFonts.dmSans(
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.black,
                      //           shadows: <Shadow>[
                      //             Shadow(
                      //               offset: Offset(3.0, 3.0),
                      //               blurRadius: 3.0,
                      //               color: Colors.white,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      if (shoppingExperience.cartItems.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: AppConst.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Sub Total',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Rs. ${shoppingExperience.getSubtotal()}',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Delivery Fee',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Rs. 50',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Tax (13%)',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Rs. ${shoppingExperience.getTax()}',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Total',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Rs. ${shoppingExperience.getTotal().toStringAsFixed(0)}',
                                      style: GoogleFonts.dmSans(
                                        color: AppConst.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 15,
                      ),
                      // checkout button
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
