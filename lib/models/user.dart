class BGMUser {
  String id;
  String email;
  String name;
  String phone;
  String status;
  String address;
  String allergens;

  BGMUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.status,
    required this.address,
    required this.allergens,
  });

  factory BGMUser.fromJson(Map<String, dynamic> json) {
    return BGMUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      status: json['status'],
      address: json['address'],
      allergens: json['allergens'],
    );
  }
}
