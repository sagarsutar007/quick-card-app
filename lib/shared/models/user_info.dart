class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? coverImage;
  final String? designation;
  final String? address;
  final String? about;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? youtube;
  final String? whatsapp;
  final String? threads;
  final String? website;
  final String? gender;
  final String? dob;
  final int? lock;
  final int? schoolId;
  final int status;
  final String token;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.coverImage,
    this.designation,
    this.address,
    this.about,
    this.facebook,
    this.twitter,
    this.instagram,
    this.youtube,
    this.whatsapp,
    this.threads,
    this.website,
    this.gender,
    this.dob,
    this.lock,
    required this.schoolId,
    required this.status,
    required this.token,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json, String token) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      coverImage: json['cover_image'],
      designation: json['designation'],
      address: json['address'],
      about: json['about'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      youtube: json['youtube'],
      whatsapp: json['whatsapp'],
      threads: json['threads'],
      website: json['website'],
      gender: json['gender'],
      dob: json['dob'],
      lock: json['lock'],
      schoolId: json['school_id'],
      status: json['status'],
      token: token,
    );
  }

  factory UserInfo.fromSavedJson(Map<String, dynamic> json) {
    return UserInfo.fromJson(json, json['token']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'designation': designation,
      'address': address,
      'about': about,
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'youtube': youtube,
      'whatsapp': whatsapp,
      'threads': threads,
      'website': website,
      'gender': gender,
      'dob': dob,
      'lock': lock,
      'school_id': schoolId,
      'status': status,
      'token': token,
    };
  }
}
