class PlanMeal {
  String name;
  List<MealType> items;

  PlanMeal({
    required this.name,
    required this.items,
  });
}

class MealType {
  String id;
  String productID;
  String productName;
  String vendorID;
  String title;
  String price;
  String calories;
  String weight;
  int quantity;

  MealType({
    required this.id,
    required this.productID,
    required this.productName,
    required this.vendorID,
    required this.title,
    required this.price,
    required this.calories,
    required this.weight,
    this.quantity = 0,
  });

  factory MealType.fromJson(Map<String, dynamic> json) {
    return MealType(
      id: json['id'],
      productID: json['productID'],
      productName: json['productName'],
      vendorID: json['vendorID'],
      title: json['title'],
      price: json['price'],
      calories: json['calories'],
      weight: json['weight'],
      quantity: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productID': productID,
      'productName': productName,
      'vendorID': vendorID,
      'title': title,
      'price': price,
      'calories': calories,
      'weight': weight,
      'quantity': quantity,
    };
  }
}

class DisplayPlan {
  String id;
  String vendorID;
  String name;
  String description;
  String totalCalories;
  String totalPrice;
  List<PlanContent> contents;

  DisplayPlan({
    required this.id,
    required this.vendorID,
    required this.name,
    required this.description,
    required this.totalCalories,
    required this.totalPrice,
    required this.contents,
  });

  factory DisplayPlan.fromJson(Map<String, dynamic> json) {
    return DisplayPlan(
      id: json['id'],
      vendorID: json['vendorID'],
      name: json['name'],
      description: json['description'],
      totalCalories: json['totalCalories'],
      totalPrice: json['totalPrice'],
      contents: json['contents']
          .map<PlanContent>((content) => PlanContent.fromJson(content))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorID': vendorID,
      'name': name,
      'description': description,
      'totalCalories': totalCalories,
      'totalPrice': totalPrice,
    };
  }
}

class PlanContent {
  String id;
  String planID;
  String productTypeID;
  String quantity;
  MealType mealType;

  PlanContent({
    required this.id,
    required this.planID,
    required this.productTypeID,
    required this.quantity,
    required this.mealType,
  });

  factory PlanContent.fromJson(Map<String, dynamic> json) {
    MealType mealType = MealType.fromJson(json['productType']);
    mealType.quantity = int.parse(json['quantity']);
    return PlanContent(
      id: json['id'],
      planID: json['planID'],
      productTypeID: json['productTypeID'],
      quantity: json['quantity'],
      mealType: mealType,
    );
  }
}
