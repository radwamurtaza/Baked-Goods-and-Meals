import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/customer/community_tab.dart';
import 'package:bgm/customer/order_history.dart';
import 'package:bgm/customer/products_and_plans.dart';
import 'package:bgm/customer/settings.dart';
import 'package:bgm/customer/vendor_info.dart';
import 'package:bgm/models/vendor.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();

  List<Vendor> searchedVendors = [];
  bool isSearching = false;

  searchVendor(String query) async {
    setState(() {
      isSearching = true;
      searchedVendors.clear();
    });
    var response = await http.post(
      Uri.parse(
        APIRoutes.searchVendors,
      ),
      body: {
        "vendorName": query,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      jsonResponse['vendors'].forEach((vendor) {
        searchedVendors.add(
          Vendor.fromJson(vendor),
        );
      });
      setState(() {
        isSearching = false;
      });
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
        child: SingleChildScrollView(
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
                height: 15,
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
              Text(
                searchController.text.isNotEmpty ? 'Search Results' : 'WELCOME',
                style: GoogleFonts.dmSans(
                  color: AppConst.secondaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    searchVendor(value);
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        CupertinoIcons.search_circle,
                        size: 25,
                        color: AppConst.secondaryColor,
                      ),
                    ),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {});
                            },
                            child: Icon(
                              CupertinoIcons.delete_left_fill,
                              size: 30,
                              color: AppConst.accentColor,
                            ),
                          ),
                    border: OutlineInputBorder(),
                    hintText: 'Search',
                    hintStyle: GoogleFonts.dmSans(
                      color: AppConst.secondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                    filled: true,
                    fillColor: AppConst.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (searchController.text.isNotEmpty &&
                  !isSearching &&
                  searchedVendors.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    itemCount: searchedVendors.length,
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
                                  id: searchedVendors[index].id,
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
                                leading: CachedNetworkImage(
                                  imageUrl: searchedVendors[index].bannerURL,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                title: Text(
                                  searchedVendors[index].name,
                                  style: GoogleFonts.dmSans(
                                    color: AppConst.secondaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: searchedVendors[index].rating == "0.0"
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                            width: 5,
                                          ),
                                          Text(
                                            " ${searchedVendors[index].rating}",
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
                                            width: 5,
                                          ),
                                          Icon(Icons.star,
                                              color: Colors.yellow),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (searchController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => ProductsPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppConst.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/products_ic.png",
                                  height: 75,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Products & Plans',
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
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => SettingsPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppConst.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/settings.png",
                                  height: 75,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Settings',
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
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => OrderHistory(),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppConst.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/orders_ic.png",
                                  height: 75,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'History',
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
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => CommunityPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppConst.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/community_ic.png",
                                  height: 75,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Community',
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
                        height: 25,
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
