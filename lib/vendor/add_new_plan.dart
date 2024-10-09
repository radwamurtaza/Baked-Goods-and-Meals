import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/models/plan.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewPlan extends StatefulWidget {
  const AddNewPlan({super.key});

  @override
  State<AddNewPlan> createState() => _AddNewPlanState();
}

class _AddNewPlanState extends State<AddNewPlan> {
  List<PlanMeal> planMeals = [];

  List<MealType> meals = <MealType>[];

  TextEditingController mealTitle = TextEditingController();
  TextEditingController planTitle = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    getVendorProducts();
  }

  getVendorProducts() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? vendorID = preferences.getString("id");
    var response = await http.post(
      Uri.parse(
        APIRoutes.getVendorProducts,
      ),
      body: {
        "vendorID": vendorID,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        meals = jsonResponse['productTypes']
            .map<MealType>((meal) => MealType.fromJson(meal))
            .toList();
      });
    }
  }

  addPlan() async {
    if (planTitle.text.isNotEmpty && planMeals.isNotEmpty) {
      setState(() {
        isProcessing = true;
      });
      Fluttertoast.showToast(
          msg: "Adding plan, please wait...", toastLength: Toast.LENGTH_LONG);
      String description = "";
      int totalCalories = 0;
      int totalPrice = 0;
      List<MealType> sendableContents = [];
      planMeals.forEach((element) {
        description += "\n• " + element.name + "\n";
        element.items.forEach((_item) {
          description += _item.quantity.toString() +
              " x " +
              _item.productName +
              " (" +
              _item.weight +
              ")  ";
          totalCalories += int.parse(_item.calories) * _item.quantity;
          totalPrice += int.parse(_item.price) * _item.quantity;
          // sendableContents.add(item);
          // if sendable content already has the same id, only increase quantity
          bool found = false;
          sendableContents.forEach((content) {
            if (content.id == _item.id) {
              found = true;
              content.quantity += _item.quantity;
            }
          });
          if (!found) {
            sendableContents.add(
              MealType(
                id: _item.id,
                productID: _item.productID,
                productName: _item.productName,
                vendorID: _item.vendorID,
                title: _item.title,
                price: _item.price,
                calories: _item.calories,
                weight: _item.weight,
                quantity: _item.quantity,
              ),
            );
          }
        });
      });
      var mealsJson = sendableContents.map((meal) => meal.toJson()).toList();
      print(mealsJson);
      print(description);
      print("TOTAL CALORIES: $totalCalories");
      print("TOTAL PRICE: $totalPrice");
      print(mealsJson);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await http.post(
        Uri.parse(APIRoutes.addPlan),
        body: {
          "vendorID": prefs.getString("id").toString(),
          "name": planTitle.text,
          "description": description,
          "totalCalories": totalCalories.toString(),
          "totalPrice": totalPrice.toString(),
          "contents": jsonEncode(mealsJson),
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      setState(() {
        isProcessing = false;
      });
      Fluttertoast.showToast(msg: jsonResponse['message']);
      if (jsonResponse['status'] == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => VendorDashboard(),
          ),
          (route) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all the fields and add atleast 1 product type.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProcessing
          ? GestureDetector(
              onTap: () {
                setState(() {
                  isProcessing = false;
                });
              },
              child: Center(
                child: CircularProgressIndicator(
                  color: AppConst.secondaryColor,
                ),
              ),
            )
          : null,
      body: SafeArea(
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
                        'Add Plan',
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
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Name',
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
                        controller: planTitle,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          filled: true,
                          fillColor: AppConst.primaryColor,
                        ),
                        cursorHeight: 0.5,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            'Plan Meals',
                            style: GoogleFonts.dmSans(
                              color: AppConst.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setModalState) {
                                      return Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                              ),
                                              Text(
                                                "Add Meal Type",
                                                style: GoogleFonts.dmSans(
                                                  color:
                                                      AppConst.secondaryColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25,
                                              ),
                                              TextField(
                                                controller: mealTitle,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.all(8),
                                                  filled: true,
                                                  hintText:
                                                      "Meal Title eg. Breakfast",
                                                  hintStyle: GoogleFonts.dmSans(
                                                    color: AppConst.accentColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  fillColor:
                                                      AppConst.primaryColor,
                                                ),
                                                cursorHeight: 0.5,
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              // meals dropdown
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.5,
                                                child: Scrollbar(
                                                  thickness: 10,
                                                  thumbVisibility: true,
                                                  trackVisibility: true,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        title: Text(
                                                          meals[index]
                                                                  .productName +
                                                              " (" +
                                                              meals[index]
                                                                  .title +
                                                              ")",
                                                          style: GoogleFonts
                                                              .irishGrover(
                                                            color: AppConst
                                                                .secondaryColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        trailing: Text(
                                                          meals[index]
                                                                  .calories +
                                                              "KCAL | " +
                                                              " " +
                                                              meals[index]
                                                                  .weight +
                                                              "g",
                                                          style: GoogleFonts
                                                              .irishGrover(
                                                            color: AppConst
                                                                .secondaryColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        subtitle: Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                setModalState(
                                                                    () {
                                                                  if (meals[index]
                                                                          .quantity >
                                                                      0) {
                                                                    meals[index]
                                                                        .quantity--;
                                                                  }
                                                                });
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
                                                              meals[index]
                                                                  .quantity
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
                                                                setModalState(
                                                                    () {
                                                                  meals[index]
                                                                      .quantity++;
                                                                });
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
                                                      );
                                                    },
                                                    itemCount: meals.length,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (mealTitle.text.isEmpty) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please enter meal title");
                                                    return;
                                                  }
                                                  List<MealType> _items = [];
                                                  meals.forEach((meal) {
                                                    if (meal.quantity > 0) {
                                                      print(
                                                          "Adding ${meal.quantity} ${meal.productName} to plan meals");
                                                      _items.add(
                                                        MealType(
                                                          id: meal.id,
                                                          productID:
                                                              meal.productID,
                                                          productName:
                                                              meal.productName,
                                                          vendorID:
                                                              meal.vendorID,
                                                          title: meal.title,
                                                          price: meal.price,
                                                          calories:
                                                              meal.calories,
                                                          weight: meal.weight,
                                                          quantity:
                                                              meal.quantity,
                                                        ),
                                                      );
                                                      meal.quantity = 0;
                                                    }
                                                  });
                                                  if (_items.isEmpty) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please select atleast 1 meal type");
                                                    return;
                                                  }
                                                  setModalState(() {
                                                    setState(() {
                                                      planMeals.add(
                                                        PlanMeal(
                                                          name: mealTitle.text,
                                                          items: _items,
                                                        ),
                                                      );
                                                    });
                                                  });
                                                  meals.forEach((element) {
                                                    element.quantity = 0;
                                                  });
                                                  mealTitle.clear();
                                                  Navigator.pop(context);
                                                },
                                                child: Card(
                                                  elevation: 4,
                                                  color:
                                                      AppConst.secondaryColor,
                                                  child: ListTile(
                                                    title: Center(
                                                      child: Text(
                                                        'Add',
                                                        style: GoogleFonts
                                                            .irishGrover(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    leading: Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: AppConst.secondaryColor),
                                ),
                                child: Center(
                                  child: Text(
                                    '+ Add',
                                    style: GoogleFonts.dmSans(
                                      color: AppConst.secondaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: planMeals.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            color: AppConst.primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        planMeals[index].name,
                                        style: GoogleFonts.dmSans(
                                          color: AppConst.secondaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            planMeals.removeAt(index);
                                          });
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: AppConst.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        title: Text(
                                          planMeals[index]
                                                  .items[i]
                                                  .quantity
                                                  .toString() +
                                              " x " +
                                              planMeals[index]
                                                  .items[i]
                                                  .productName +
                                              " (" +
                                              planMeals[index].items[i].title +
                                              ")",
                                          style: GoogleFonts.dmSans(
                                            color: AppConst.secondaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Text(
                                          planMeals[index].items[i].calories +
                                              "KCAL | " +
                                              " " +
                                              planMeals[index].items[i].weight +
                                              "g",
                                          style: GoogleFonts.dmSans(
                                            color: AppConst.secondaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: planMeals[index].items.length,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          addPlan();
                        },
                        child: Card(
                          elevation: 4,
                          color: AppConst.secondaryColor,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                'Add Plan',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            leading: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
