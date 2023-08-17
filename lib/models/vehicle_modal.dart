class Vehicle {
  final String? id;
  final String vehicleName;
  final String vehicleNumber;
  final String vehicleType;

  Vehicle({
    this.id,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['vehicleId'],
      vehicleName: json['vehicleName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
    );
  }
}
