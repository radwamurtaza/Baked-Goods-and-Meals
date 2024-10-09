class Vendor {
  String id;
  String name;
  String email;
  String description;
  String status;
  String bannerURL;
  String rating;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.status,
    required this.bannerURL,
    required this.rating,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      description: json['description'],
      status: json['status'],
      bannerURL: json['bannerURL'],
      rating: json['rating'],
    );
  }
}
