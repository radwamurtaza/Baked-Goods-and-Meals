class BGMOrder {
  String id;
  String userID;
  String vendorID;
  String vendorName;
  String orderItems;
  String status;
  String createdAt;
  String updatedAt;
  String userName;
  String userAllergens;
  String deliveryAddress;
  String subtotal;
  String deliveryCharges;
  String taxes;
  String total;

  BGMOrder({
    required this.id,
    required this.userID,
    required this.vendorID,
    required this.vendorName,
    required this.orderItems,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userAllergens,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharges,
    required this.taxes,
    required this.total,
  });

  factory BGMOrder.fromJson(Map<String, dynamic> json) {
    return BGMOrder(
      id: json['id'],
      userID: json['userID'],
      vendorID: json['vendorID'],
      vendorName: json['vendorName'],
      orderItems: json['orderItems'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userName: json['userName'],
      userAllergens: json['userAllergens'],
      deliveryAddress: json['deliveryAddress'],
      subtotal: json['subtotal'],
      deliveryCharges: json['deliveryCharges'],
      taxes: json['taxes'],
      total: json['total'],
    );
  }
}

class HistoryTile {
  String id;
  String userID;
  String vendorID;
  String vendorName;
  String orderItems;
  String status;
  String createdAt;
  String updatedAt;
  String userName;
  String userAllergens;
  String deliveryAddress;
  String subtotal;
  String deliveryCharges;
  String taxes;
  String total;
  String rating;

  HistoryTile({
    required this.id,
    required this.userID,
    required this.vendorID,
    required this.vendorName,
    required this.orderItems,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userAllergens,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharges,
    required this.taxes,
    required this.total,
    required this.rating,
  });

  factory HistoryTile.fromJson(Map<String, dynamic> json) {
    return HistoryTile(
      id: json['id'],
      userID: json['userID'],
      vendorID: json['vendorID'],
      vendorName: json['vendorName'],
      orderItems: json['orderItems'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userName: json['userName'],
      userAllergens: json['userAllergens'],
      deliveryAddress: json['deliveryAddress'],
      subtotal: json['subtotal'],
      deliveryCharges: json['deliveryCharges'],
      taxes: json['taxes'],
      total: json['total'],
      rating: json['rating'],
    );
  }
}
