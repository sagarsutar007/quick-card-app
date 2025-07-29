class SchoolModel {
  final int id;
  final String schoolName;
  final String schoolCode;
  final String? udiseNo;
  final String? address;
  final String districtName;
  final String blockName;
  final String clusterName;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
    this.udiseNo,
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
      udiseNo:
          (json['udise_no'] != null &&
              json['udise_no'].toString().trim().isNotEmpty)
          ? json['udise_no']
          : 'No UDISE Number',

      address:
          (json['school_address'] != null &&
              json['school_address'].toString().trim().isNotEmpty)
          ? json['school_address']
          : 'No Address',
      districtName: json['district_name'],
      blockName: json['block_name'],
      clusterName: json['cluster_name'],
    );
  }
}
