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
    return Vehicle(
      id: json['id'] ?? json['vehicleId'],
      vehicleName: json['vehicleName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      capacity: json['capacity'] ?? 4,
      color: json['color'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      fuelType: json['fuelType'],
      fuelEfficiency: json['fuelEfficiency'],
      features: json['features'] != null 
          ? List<String>.from(json['features']) 
          : [],
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : [],
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
