import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/models/plan.dart';
import 'package:bgm/models/product.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/vendor/add_new_plan.dart';
import 'package:bgm/vendor/add_new_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllVendorProducts extends StatefulWidget {
  bool isProduct;

  AllVendorProducts({required this.isProduct});

  @override
  State<AllVendorProducts> createState() => _AllVendorProductsState();
}

class _AllVendorProductsState extends State<AllVendorProducts>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Product> products = [];
  List<DisplayPlan> plans = [];

  String vendorName = "";

  // int currentIndex = 0;

  bool isGettingData = true;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      initialIndex: widget.isProduct ? 0 : 1,
      vsync: this,
    );
    getVendorData();
    super.initState();
  }

  getVendorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    String? id = prefs.getString("id");
    var response = await http.post(
      Uri.parse(APIRoutes.getVendor),
      body: {
        "vendorID": id,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        vendorName = jsonResponse['vendor']['name'];
      });
      List<Product> products = [];
      for (var product in jsonDecode(jsonEncode(jsonResponse['products']))) {
        // print(product);

        List<ProductType> types = [];
        for (var type in product['types']) {
          types.add(
            ProductType(
              id: type['id'],
              title: type['title'],
              price: type['price'],
              calories: type['calories'],
              weight: type['weight'],
            ),
          );
          print(type);
        }
        products.add(
          Product(
            id: product['id'],
            name: product['name'],
            types: types,
          ),
        );
      }
      List<DisplayPlan> _plans = [];
      for (var plan in jsonDecode(jsonEncode(jsonResponse['plans']))) {
        _plans.add(
          DisplayPlan(
            id: plan['id'],
            vendorID: plan['vendorID'],
            name: plan['name'],
            description: plan['description'],
            totalCalories: plan['totalCalories'],
            totalPrice: plan['totalPrice'],
            contents: plan['contents']
                .map<PlanContent>((content) => PlanContent.fromJson(content))
                .toList(),
          ),
        );
      }
      setState(() {
        this.products = products;
        this.plans = _plans;
        isGettingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                      getVendorData();
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (_tabController!.index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewProduct(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewPlan(),
                ),
              );
            }
          },
          label: Text(
            _tabController!.index == 0 ? "Add Product" : "Add Plan",
            style: GoogleFonts.dmSans(
              color: AppConst.secondaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.add_box_outlined, color: AppConst.secondaryColor),
          backgroundColor: Colors.white,
        ),
        body: isGettingData
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                  //  image: DecorationImage(
                    //  image: AssetImage('assets/bg.png'),
                      //fit: BoxFit.cover,
                    //),
                  ),
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
                                  'Vendor: $vendorName',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _tabController!.animateTo(0);
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _tabController!.index == 0
                                    ? AppConst.accentColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Products",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _tabController!.animateTo(1);
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _tabController!.index == 1
                                    ? AppConst.accentColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Plans",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            ListView.builder(
                              itemCount: products.length,
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
                                          '${(index + 1).toString()}. ${products[index].name}',
                                          style: GoogleFonts.dmSans(
                                            color: AppConst.secondaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var type
                                                in products[index].types)
                                              Text(
                                                '• ${type.title} (${type.weight}g - ${type.calories} Kcal) - Rs. ${type.price}',
                                                style: GoogleFonts.dmSans(
                                                  color: AppConst.accentColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListView.builder(
                              itemCount: plans.length,
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
                                          plans[index].name +
                                              " - Rs. ${plans[index].totalPrice} (${plans[index].totalCalories} KCAL)",
                                          style: GoogleFonts.dmSans(
                                            color: AppConst.secondaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          plans[index].description,
                                          style: GoogleFonts.dmSans(
                                            color: AppConst.accentColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
