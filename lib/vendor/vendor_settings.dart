import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/cart_page.dart';
import 'package:bgm/customer/edit_profile.dart';
import 'package:bgm/models/vendor.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:bgm/vendor/vendor_reviews.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VendorSettings extends StatefulWidget {
  @override
  State<VendorSettings> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<VendorSettings> {
  bool isBanned = false;
  String? vendorImage;
  Vendor? vendor;

  bool isAdmin = false;

  bool isProcessing = false;

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getVendorData();
  }

  getVendorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isAdmin")!) {
      setState(() {
        isAdmin = true;
      });
    }
    var response = await http.post(
      Uri.parse(APIRoutes.getVendor),
      body: {
        "vendorID": prefs.getString("id")!,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      setState(() {
        vendor = Vendor.fromJson(jsonResponse['vendor']);
        nameController.text = vendor!.name;
        isBanned = vendor!.status != "active";
      });
    }
  }

  saveVendorData() async {
    setState(() {
      isProcessing = true;
    });
    String bannerURL = vendor!.bannerURL;
    if (vendorImage != null) {
      bannerURL = await uploadFile(File(vendorImage!));
    }
    var response = await http.post(
      Uri.parse(APIRoutes.updateVendor),
      body: {
        "id": vendor!.id,
        "name": nameController.text,
        "bannerURL": bannerURL,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == 200) {
      Fluttertoast.showToast(
        msg: "Vendor Updated Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isProcessing = false;
      });
      Provider.of<ShoppingExperience>(context, listen: false)
          .customerName
          .value = nameController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("name", nameController.text);
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => VendorDashboard(),
        ),
        (route) => false,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Something went wrong, please try again later",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<String> uploadFile(File _image) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('posts/${_image.path}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() => null);

    return await storageReference.getDownloadURL();
  }

  selectImageType(BuildContext context, bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(false);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.photo,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(true);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.camera,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getImage(bool isCamera) async {
    var image = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 40);
    File imageF = File(image!.path);
    final bytes = imageF.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb > 10) {
      Fluttertoast.showToast(
        msg: "Image is larger than 5 mb, please upload a smaller image",
      );
    } else {
      setState(() {
        vendorImage = image.path;
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
        child: vendor == null
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
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
                              'Profile & Reviews',
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Business Banner',
                              style: GoogleFonts.dmSans(
                                color: AppConst.secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 150,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      vendorImage == null
                                          ? Image.network(
                                              vendor!.bannerURL,
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.file(
                                                File(
                                                  vendorImage!,
                                                ),
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      ElevatedButton(
                                        child: Text('SELECT'),
                                        onPressed: () {
                                          selectImageType(context, true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            // fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                                "* For optimal results, use a banner in landscape mode."),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Display Name',
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
                              controller: nameController,
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
                            SizedBox(
                              height: 25,
                            ),
                            if (isProcessing)
                              Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            if (!isProcessing)
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      saveVendorData();
                                    },
                                    child: Text(
                                      "SAVE",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(1.0, 2.0),
                                            blurRadius: 0.5,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: AppConst.primaryColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Reviews:",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 2.0),
                                        blurRadius: 0.5,
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
                                  " ${vendor!.rating}",
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
                            SizedBox(
                              height: 10,
                            ),
                            if (!isBanned && isAdmin)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      var response = await http.post(
                                        Uri.parse(APIRoutes.banVendor),
                                        body: {
                                          "id": vendor!.id,
                                        },
                                      );
                                      var jsonResponse =
                                          jsonDecode(response.body);

                                      if (jsonResponse['status'] == 200) {
                                        setState(() {
                                          isBanned = true;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Vendor Banned Successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        "Ban Vendor",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(3.0, 3.0),
                                              blurRadius: 3.0,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (isBanned && isAdmin)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      var response = await http.post(
                                        Uri.parse(APIRoutes.unbanVendor),
                                        body: {
                                          "id": vendor!.id,
                                        },
                                      );
                                      var jsonResponse =
                                          jsonDecode(response.body);

                                      if (jsonResponse['status'] == 200) {
                                        setState(() {
                                          isBanned = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg: "Vendor unbanned Successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        "Unban Vendor",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(3.0, 3.0),
                                              blurRadius: 3.0,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 25,
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
