class Vehicle {
  final String? id;
  final String vehicleName;
  final String vehicleNumber;
  final String vehicleType;
  final int capacity;
  final String? color;
  final String? make;
  final String? model;
  final String? year;
  final String? fuelType;
  final String? fuelEfficiency;
  final List<String>? features;
  final List<String>? photos;
  final bool isActive;

  Vehicle({
    this.id,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.vehicleType,
    this.capacity = 4,
    this.color,
    this.make,
    this.model,
    this.year,
    this.fuelType,
    this.fuelEfficiency,
    this.features,
    this.photos,
    this.isActive = true,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return Vehicle(
        vehicleName: 'Unknown',
        vehicleNumber: 'Unknown',
        vehicleType: 'Car',
        capacity: 4,
      );
    }

    // Parse capacity to an integer
    int capacity = 4;
    if (json['capacity'] != null) {
      if (json['capacity'] is int) {
        capacity = json['capacity'];
      } else {
        capacity = int.tryParse(json['capacity'].toString()) ?? 4;
      }
    }
    
    // Get features and photos if available
    List<String> features = [];
    if (json['features'] is List) {
      features = List<String>.from(json['features']);
    }
    
    List<String> photos = [];
    if (json['photos'] is List) {
      photos = List<String>.from(json['photos']);
    }
    
    return Vehicle(
      id: json['id'] ?? json['vehicleId'],
      vehicleName: json['vehicleName'] ?? json['name'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? json['regNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? json['type'] ?? '',
      capacity: capacity,
      color: json['color'],
      make: json['make'],
      model: json['model'],
      year: json['year']?.toString(),
      fuelType: json['fuelType'],
      fuelEfficiency: json['fuelEfficiency'],
      features: features,
      photos: photos,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleName': vehicleName,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'capacity': capacity,
      if (color != null) 'color': color,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (fuelType != null) 'fuelType': fuelType,
      if (fuelEfficiency != null) 'fuelEfficiency': fuelEfficiency,
      'features': features ?? [],
      'photos': photos ?? [],
      'isActive': isActive,
    };
  }
}
