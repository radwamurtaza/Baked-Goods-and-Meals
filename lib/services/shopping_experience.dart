import 'package:bgm/models/plan.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingExperience extends ChangeNotifier {
  final cartItems = ValueNotifier<List<MealType>>([]);
  final cartVendorID = ValueNotifier<String>("");
  final customerID = ValueNotifier<String>("");
  final customerName = ValueNotifier<String>("");
  final customerEmail = ValueNotifier<String>("");

  ShoppingExperience() {
    getUserData();
  }

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerName.value = prefs.getString("name")!;
    customerEmail.value = prefs.getString("email")!;
    customerID.value = prefs.getString("id")!;
    notifyListeners();
  }

  addToCart(MealType item) {
    if (cartItems.value.isEmpty) {
      cartVendorID.value = item.vendorID;
    }
    if (cartVendorID.value != item.vendorID) {
      Fluttertoast.showToast(
          msg:
              "Your cart has items from other vendors, Please clear before proceeding with this vendor");
      return;
    }
    bool found = false;
    for (int i = 0; i < cartItems.value.length; i++) {
      if (cartItems.value[i].id == item.id) {
        found = true;
        cartItems.value[i].quantity =
            cartItems.value[i].quantity + item.quantity;
        break;
      }
    }
    if (found == false) {
      cartItems.value.add(item);
    }
    notifyListeners();
  }

  int getQuantity(String itemID) {
    for (int i = 0; i < cartItems.value.length; i++) {
      if (cartItems.value[i].id == itemID) {
        return cartItems.value[i].quantity;
      }
    }
    return 0;
  }

  removeFromCart(MealType item) {
    // if only 1 left then remove else deduct quantity
    for (int i = 0; i < cartItems.value.length; i++) {
      if (cartItems.value[i].id == item.id) {
        if (cartItems.value[i].quantity == 1) {
          cartItems.value.removeAt(i);
        } else {
          cartItems.value[i].quantity--;
        }
        break;
      }
    }
    notifyListeners();
  }

  double getSubtotal() {
    double total = 0;
    for (int i = 0; i < cartItems.value.length; i++) {
      total = total +
          (double.parse(cartItems.value[i].price) *
              cartItems.value[i].quantity);
    }
    return total;
  }

  double getTax() {
    double total = 0;
    for (int i = 0; i < cartItems.value.length; i++) {
      total = total +
          (double.parse(cartItems.value[i].price) *
              cartItems.value[i].quantity);
    }
    double thirteenPercent = total * 0.13;
    return thirteenPercent;
  }

  double getTotal() {
    double total = 0;
    for (int i = 0; i < cartItems.value.length; i++) {
      total = total +
          (double.parse(cartItems.value[i].price) *
              cartItems.value[i].quantity);
    }

    double thirteenPercent = total * 0.13;
    return total + 50 + thirteenPercent;
  }
}
