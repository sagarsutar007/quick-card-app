class AuthorityRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? address;

  AuthorityRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    if (address != null) 'address': address,
  };
}
