import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/models/plan.dart';
import 'package:bgm/models/product.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/vendor/add_new_plan.dart';
import 'package:bgm/vendor/add_new_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bgm/customer/home_page.dart';


class VendorInfoPage extends StatefulWidget {
  String id;
  

  VendorInfoPage({
    required this.id,
  });

  @override
  State<VendorInfoPage> createState() => _VendorInfoPageState();
}

class _VendorInfoPageState extends State<VendorInfoPage>
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
      initialIndex: 0,
      vsync: this,
    );
    getVendorData();
    super.initState();
  }

  getVendorData() async {
    var response = await http.post(
      Uri.parse(APIRoutes.getVendor),
      body: {
        "vendorID": widget.id,
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
    return Consumer<ShoppingExperience>(
        builder: (context, shoppingExperience, _) {
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
                         Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => HomePage(),
                      ),
                    );
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
          body: isGettingData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(''),
                        fit: BoxFit.cover,
                      ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                ListTile(
                                                  visualDensity: VisualDensity(
                                                    horizontal: -4,
                                                    vertical: -4,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  dense: true,
                                                  title: Text(
                                                    '• ${type.title} (${type.weight}g - ${type.calories} Kcal) - Rs. ${type.price}',
                                                    style: GoogleFonts.dmSans(
                                                      color:
                                                          AppConst.accentColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: shoppingExperience
                                                              .getQuantity(
                                                                  type.id) ==
                                                          0
                                                      ? null
                                                      : Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                shoppingExperience
                                                                    .removeFromCart(
                                                                  MealType(
                                                                    id: type.id,
                                                                    productID:
                                                                        products[index]
                                                                            .id,
                                                                    productName:
                                                                        products[index]
                                                                            .name,
                                                                    title: type
                                                                        .title,
                                                                    price: type
                                                                        .price,
                                                                    calories: type
                                                                        .calories,
                                                                    weight: type
                                                                        .weight,
                                                                    quantity: 1,
                                                                    vendorID:
                                                                        widget
                                                                            .id,
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                "-",
                                                                style: GoogleFonts
                                                                    .irishGrover(
                                                                  color: AppConst
                                                                      .accentColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 30,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              shoppingExperience
                                                                  .getQuantity(
                                                                      type.id)
                                                                  .toString(),
                                                              style: GoogleFonts
                                                                  .irishGrover(
                                                                color: AppConst
                                                                    .accentColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                shoppingExperience
                                                                    .addToCart(
                                                                  MealType(
                                                                    id: type.id,
                                                                    productID:
                                                                        products[index]
                                                                            .id,
                                                                    productName:
                                                                        products[index]
                                                                            .name,
                                                                    title: type
                                                                        .title,
                                                                    price: type
                                                                        .price,
                                                                    calories: type
                                                                        .calories,
                                                                    weight: type
                                                                        .weight,
                                                                    quantity: 1,
                                                                    vendorID:
                                                                        widget
                                                                            .id,
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                "+",
                                                                style: GoogleFonts
                                                                    .irishGrover(
                                                                  color: AppConst
                                                                      .accentColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 30,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  trailing: shoppingExperience
                                                              .getQuantity(
                                                                  type.id) ==
                                                          0
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            shoppingExperience
                                                                .addToCart(
                                                              MealType(
                                                                id: type.id,
                                                                productID:
                                                                    products[
                                                                            index]
                                                                        .id,
                                                                productName:
                                                                    products[
                                                                            index]
                                                                        .name,
                                                                title:
                                                                    type.title,
                                                                price:
                                                                    type.price,
                                                                calories: type
                                                                    .calories,
                                                                weight:
                                                                    type.weight,
                                                                quantity: 1,
                                                                vendorID:
                                                                    widget.id,
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppConst
                                                                  .secondaryColor,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : null,
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
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListTile(
                                              title: Text(
                                                plans[index].name +
                                                    " - Rs. ${plans[index].totalPrice} (${plans[index].totalCalories} KCAL)",
                                                style: GoogleFonts.dmSans(
                                                  color:
                                                      AppConst.secondaryColor,
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
                                          InkWell(
                                            onTap: () {
                                              plans[index].contents.forEach(
                                                (element) {
                                                  shoppingExperience.addToCart(
                                                    element.mealType,
                                                  );
                                                  print(element.mealType
                                                      .toJson());
                                                },
                                              );
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Plan added to cart successfully");
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppConst.secondaryColor,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Center(
                                                  child: Text(
                                                    "Add Plan To Cart",
                                                    style: GoogleFonts.dmSans(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
    });
  }
}
