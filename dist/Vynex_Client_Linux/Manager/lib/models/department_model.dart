class DepartmentModel {
  final int departmentId;
  final String name;
  final String? description;
  final int? managerId;
  final String? managerName;
  final int memberCount;
  final int deviceCount;

  DepartmentModel({
    required this.departmentId,
    required this.name,
    this.description,
    this.managerId,
    this.managerName,
    this.memberCount = 0,
    this.deviceCount = 0,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      departmentId: json['department_id'] is int ? json['department_id'] : int.tryParse(json['department_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      managerId: json['manager_id'] is int ? json['manager_id'] : int.tryParse(json['manager_id']?.toString() ?? ''),
      managerName: json['manager_name'],
      memberCount: json['member_count'] ?? 0,
      deviceCount: json['device_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': departmentId,
      'name': name,
      'description': description,
      'manager_id': managerId,
    };
  }
}
