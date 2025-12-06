class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String> imagesPath = [];
  String? lat;
  String? lng;
  String? createdAt;
  String? name;
  String? email;
  String? phone;
  String? regDate;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagesPath = const [],
    this.lat,
    this.lng,
    this.createdAt,
    this.name,
    this.email,
    this.phone,
    this.regDate,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    imagesPath = json['images_path'] != null
        ? json['images_path'].toString().split(",")
        : [];
    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    data['images_path'] = imagesPath.join(",");
    data['lat'] = lat;
    data['lng'] = lng;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['reg_date'] = regDate;
    return data;
  }
}
