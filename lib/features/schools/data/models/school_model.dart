class SchoolModel {
  final int id;
  final String schoolName;
  final String schoolCode;
  final String udiseNo;
  final String? address;
  final String districtName;
  final String blockName;
  final String clusterName;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
    required this.udiseNo,
    this.address,
    required this.districtName,
    required this.blockName,
    required this.clusterName,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      schoolName: json['school_name'],
      schoolCode: json['school_code'],
      udiseNo: json['udise_no'],
      address: json['school_address'],
      districtName: json['district_name'],
      blockName: json['block_name'],
      clusterName: json['cluster_name'],
    );
  }
}
