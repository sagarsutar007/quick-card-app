class User {
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
  final String gender;
  final String? dob;
  final int? schoolId;
  final int status;
  final String token;

  User({
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
    required this.gender,
    this.dob,
    required this.schoolId,
    required this.status,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
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
      schoolId: json['school_id'],
      status: json['status'],
      token: token,
    );
  }
}
