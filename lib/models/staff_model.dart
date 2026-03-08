class StaffModel {
  final int id;
  final String staffId;
  final String name;
  final String phone;
  final String designation;
  final String role;
  final String dob;
  final String salary;

  StaffModel({
    required this.id,
    required this.staffId,
    required this.name,
    required this.phone,
    required this.designation,
    required this.role,
    required this.dob,
    required this.salary,
  });

  factory StaffModel.fromApi(Map<String, dynamic> json) {
    return StaffModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      staffId: json['staffid'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      role: json['role'] ?? '',
      dob: json['dob'] ?? '',
      salary: json['salary']?.toString() ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'staffid': staffId,
      'name': name,
      'phone': phone,
      'designation': designation,
      'role': role,
      'dob': dob,
      'salary': salary,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id.toString(),
      'StaffID': staffId,
      'Name': name,
      'Phone': phone,
      'Designation': designation,
      'Role': role,
      'DOB': dob,
      'Salary': salary,
    };
  }
}
