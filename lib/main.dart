import 'package:bgm/admin/admin_dashboard.dart';
import 'package:bgm/auth/login.dart';
import 'package:bgm/customer/home_page.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:bgm/vendor/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Widget homescreen = LoginScreen();
  String? email = prefs.getString("email");
  if (email != null) {
    if (email.contains("@bagm.com")) {
      homescreen = VendorDashboard();
    } else if (email.contains("@admin.com")) {
      homescreen = AdminDashboard();
    } else {
      homescreen = HomePage();
    }
  }
  runApp(MyApp(
    homescreen: homescreen,
  ));
}

class MyApp extends StatelessWidget {
  final Widget homescreen;
  MyApp({required this.homescreen});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShoppingExperience>(
      create: (BuildContext context) {
        return ShoppingExperience();
      },
      child: MaterialApp(
        title: 'BGM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
        ),
        home: homescreen,
      ),
    );
  }
}
