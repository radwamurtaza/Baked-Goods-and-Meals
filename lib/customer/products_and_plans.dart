import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/customer/vendor_info.dart';
import 'package:bgm/models/vendor.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bgm/customer/settings.dart';


class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _HomePageState();
}

class _HomePageState extends State<ProductsPage> {
  List<Vendor> vendors = [];

  @override
  void initState() {
    getVendors();
    super.initState();
  }

  getVendors() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getVendors,
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
      bottomNavigationBar: GestureDetector(
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
            Center(
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SettingsPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/home_ic.png",
                    ),
                  ),
                ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Products & Plans',
              style: GoogleFonts.dmSans(
                color: AppConst.secondaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            if (vendors.isEmpty) CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => VendorInfoPage(
                                id: vendors[index].id,
                              ),
                            ),
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
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: vendors[index].bannerURL,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              title: Text(
                                vendors[index].name,
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: vendors[index].rating == "0.0"
                                  ? Row(
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          elevation: 4,
                                          color: AppConst.accentColor,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              "New",
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rated",
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                      //       shadows: <Shadow>[
                                      //         Shadow(
                                      //            offset: Offset(1.0, 2.0),
                                      // blurRadius: 0.5,
                                      //           color: Colors.black,
                                      //         ),
                                      //       ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          " ${double.parse(vendors[index].rating).toStringAsFixed(
                                            1,
                                          )}",
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                      //       shadows: <Shadow>[
                                      //         Shadow(
                                      //            offset: Offset(1.0, 2.0),
                                      // blurRadius: 0.5,
                                      //           color: Colors.black,
                                      //         ),
                                      //       ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(Icons.star, color: Colors.yellow),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
