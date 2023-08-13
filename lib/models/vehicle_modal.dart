class Vehicle {
  final String vehicleName;
  final String vehicleNumber;
  final String vehicleType;

  Vehicle({
    required this.vehicleName,
    required this.vehicleNumber,
    required this.vehicleType,
  });
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleName: json['vehicleName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
    );
  }
}
