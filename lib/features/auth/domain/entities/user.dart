class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? designation;
  final String? address;
  final String? about;
  final String? coverImage;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? whatsapp;
  final String? youtube;
  final String? threads;
  final String? website;
  final String gender;
  final DateTime? dob;
  final int? schoolId;
  final int status;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.designation,
    this.address,
    this.about,
    this.coverImage,
    this.facebook,
    this.twitter,
    this.instagram,
    this.whatsapp,
    this.youtube,
    this.threads,
    this.website,
    required this.gender,
    this.dob,
    this.schoolId,
    required this.status,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      designation: json['designation'],
      address: json['address'],
      about: json['about'],
      coverImage: json['cover_image'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      whatsapp: json['whatsapp'],
      youtube: json['youtube'],
      threads: json['threads'],
      website: json['website'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      schoolId: json['school_id'],
      status: json['status'],
      token: token,
    );
  }
}
