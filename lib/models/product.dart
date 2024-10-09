class Product {
  String id;
  String name;
  List<ProductType> types;

  Product({
    this.id = "",
    required this.name,
    required this.types,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      types: json['types']
          .map<ProductType>((type) => ProductType.fromJson(type))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types.map((type) => type.toJson()).toList(),
    };
  }
}

class ProductType {
  String id;
  String title;
  String price;
  String calories;
  String weight;

  ProductType({
    required this.id,
    required this.title,
    required this.price,
    required this.calories,
    required this.weight,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      calories: json['calories'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'calories': calories,
      'weight': weight,
    };
  }
}
