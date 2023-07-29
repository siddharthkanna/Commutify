class Ride {
  final LocationData pickupLocation;
  final LocationData destinationLocation;
  final int price;
  final String time;
  final String name;
  final int availableSeats;
  final String vehicleName;

  Ride({
    required this.price,
    required this.time,
    required this.name,
    required this.availableSeats,
    required this.vehicleName,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  factory Ride.fromJson(Map<String,dynamic> json) {
    return Ride(
      name: json['driverName'] ?? 'No Name',
      price: json['price'] ?? 0,
      time: json['selectedTime'] ?? '',
      availableSeats: json['selectedCapacity'] ?? 0,
      vehicleName: json['vehicleName'] ?? '',
      destinationLocation: LocationData.fromJson(json['destinationLocation']),
      pickupLocation: LocationData.fromJson(json['pickupLocation']),
    );
  }
}

class LocationData {
  final String placeName;
  final double latitude;
  final double longitude;

  LocationData({
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      placeName: json['placeName'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }
}