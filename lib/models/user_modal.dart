class User {
  final String uid;
  final String email;
  final String name;
  final String mobileNumber;
  final List<Vehicle> vehicles;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.mobileNumber,
    required this.vehicles,
  });
}

class Vehicle {
  final String vehicleNumber;
  final String vehicleName;
  final String vehicleType;

  Vehicle({
    required this.vehicleNumber,
    required this.vehicleName,
    required this.vehicleType,
  });
}
