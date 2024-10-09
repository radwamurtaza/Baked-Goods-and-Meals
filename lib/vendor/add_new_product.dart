import 'dart:convert';

import 'package:bgm/constants/constants.dart';
import 'package:bgm/models/product.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNewProduct extends StatefulWidget {
  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  TextEditingController _nameController = TextEditingController();

  List<ProductType> _types = [];

  bool isProcessing = false;

  TextEditingController typeTitleController = TextEditingController();
  TextEditingController typePriceController = TextEditingController();
  TextEditingController typeCaloriesController = TextEditingController();
  TextEditingController typeWeightController = TextEditingController();

  addType() {
    if (typeTitleController.text.isNotEmpty &&
        typePriceController.text.isNotEmpty &&
        typeCaloriesController.text.isNotEmpty &&
        typeWeightController.text.isNotEmpty) {
      setState(() {
        _types.add(
          ProductType(
            id: "0",
            title: typeTitleController.text,
            price: typePriceController.text,
            calories: typeCaloriesController.text,
            weight: typeWeightController.text,
          ),
        );
      });
      Fluttertoast.showToast(
          msg: typeTitleController.text + " added as product type.");
      typeTitleController.clear();
      typePriceController.clear();
      typeCaloriesController.clear();
      typeWeightController.clear();
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all the fields.",
      );
    }
  }

  addProduct() async {
    if (_nameController.text.isNotEmpty && _types.isNotEmpty) {
      setState(() {
        isProcessing = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var typesJson = _types.map((type) => type.toJson()).toList();
      print(typesJson);
      var response = await http.post(
        Uri.parse(APIRoutes.addProduct),
        body: {
          "name": _nameController.text,
          "vendorID": prefs.getString("id").toString(),
          "types": jsonEncode(typesJson),
        },
      );
      var jsonResponse = jsonDecode(response.body);
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
                        'Add Product',
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
                        'Product Name',
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          filled: true,
                          fillColor: AppConst.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            'Product Sizes/Types',
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
                                              "Add Product Type",
                                              style: GoogleFonts.dmSans(
                                                color: AppConst.secondaryColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 25,
                                            ),
                                            TextField(
                                              controller: typeTitleController,
                                              onChanged: (value) {
                                                setState(() {
                                                  typeTitleController.text =
                                                      value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                filled: true,
                                                hintText:
                                                    "Type Title eg. Small",
                                                hintStyle: GoogleFonts.dmSans(
                                                  color: AppConst.accentColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                fillColor:
                                                    AppConst.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextField(
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: typePriceController,
                                              onChanged: (value) {
                                                setState(() {
                                                  typePriceController.text =
                                                      value;
                                                });
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: false,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                filled: true,
                                                hintText:
                                                    "Type Price in Rupees eg. 100",
                                                hintStyle: GoogleFonts.dmSans(
                                                  color: AppConst.accentColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                suffix: Text(
                                                  "Rs.",
                                                  style: GoogleFonts.dmSans(
                                                    color: AppConst.accentColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                fillColor:
                                                    AppConst.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextField(
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller:
                                                  typeCaloriesController,
                                              onChanged: (value) {
                                                setState(() {
                                                  typeCaloriesController.text =
                                                      value;
                                                });
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: false,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                filled: true,
                                                suffix: Text(
                                                  "KCAL",
                                                  style: GoogleFonts.dmSans(
                                                    color: AppConst.accentColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                hintText:
                                                    "Type Calories in KCAL eg. 330",
                                                hintStyle: GoogleFonts.dmSans(
                                                  color: AppConst.accentColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                fillColor:
                                                    AppConst.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextField(
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: typeWeightController,
                                              onChanged: (value) {
                                                setState(() {
                                                  typeWeightController.text =
                                                      value;
                                                });
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                decimal: false,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                filled: true,
                                                hintText:
                                                    "Type Size in Grams eg. 500g",
                                                hintStyle: GoogleFonts.dmSans(
                                                  color: AppConst.accentColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                suffix: Text(
                                                  "g",
                                                  style: GoogleFonts.dmSans(
                                                    color: AppConst.accentColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                fillColor:
                                                    AppConst.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                addType();
                                              },
                                              child: Card(
                                                elevation: 4,
                                                color: AppConst.secondaryColor,
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
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            color: AppConst.primaryColor,
                            child: ListTile(
                              title: Text(
                                _types[index].title,
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${_types[index].weight}g - ${_types[index].calories}KCAL',
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Text(
                                'Rs. ${_types[index].price}',
                                style: GoogleFonts.dmSans(
                                  color: AppConst.secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: _types.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      if (isProcessing)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isProcessing = false;
                              });
                            },
                            child: CircularProgressIndicator(
                              color: AppConst.accentColor,
                            ),
                          ),
                        ),
                      if (!isProcessing)
                        GestureDetector(
                          onTap: () {
                            addProduct();
                          },
                          child: Card(
                            elevation: 4,
                            color: AppConst.secondaryColor,
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  'Add Product',
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
