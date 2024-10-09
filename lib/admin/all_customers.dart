import 'dart:convert';

import 'package:bgm/admin/edit_profile_as_admin.dart';
import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/edit_profile.dart';
import 'package:bgm/models/user.dart';
import 'package:bgm/services/api_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AllCustomers extends StatefulWidget {
  const AllCustomers({super.key});

  @override
  State<AllCustomers> createState() => _AllCustomersState();
}

class _AllCustomersState extends State<AllCustomers> {
  List<BGMUser> users = [];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getAllUsers,
      ),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == 200) {
      jsonResponse['users'].forEach((user) {
        users.add(
          BGMUser.fromJson(user),
        );
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Admin Panel',
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
            Text(
              'All Customers (${users.length.toString()})',
              style: GoogleFonts.dmSans(
                color: AppConst.secondaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminEditProfile(
                              id: users[index].id,
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
                            trailing: Image.asset(
                              "assets/edit_ic.png",
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                              ),
                            ),
                            title: Text(
                              users[index].name + " - " + users[index].status,
                              style: GoogleFonts.dmSans(
                                color: AppConst.secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              users[index].email,
                              style: GoogleFonts.dmSans(
                                color: AppConst.accentColor,
                                fontSize: 12,
                              ),
                            ),
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
