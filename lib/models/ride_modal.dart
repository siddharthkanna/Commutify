import 'package:commutify/models/vehicle_modal.dart';

class Ride {
  final String id;
  final LocationData pickupLocation;
  final LocationData destinationLocation;
  final int price;
  final String driverNumber;
  final String time;
  final String name;
  final String driverPhotoUrl;
  final int availableSeats;
  final Vehicle vehicle;
  final String rideStatus;
  final List<Passenger> passengers;
  final String passengerStatus;
  final double? estimatedDistance;
  final double? estimatedDuration;
  
  Ride({
    required this.id,
    required this.price,
    required this.time,
    required this.name,
    required this.driverPhotoUrl,
    required this.driverNumber,
    required this.availableSeats,
    required this.vehicle,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.rideStatus,
    required this.passengers,
    required this.passengerStatus,
    this.estimatedDistance,
    this.estimatedDuration,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    try {
      // Extract ride ID (either 'id' or 'rideId')
      final String id = json['id'] ?? json['rideId'] ?? '';
      
      // Extract driver info - could be nested or flat
      final Map<String, dynamic> driver = json['driver'] is Map ? json['driver'] : {};
      final String driverName = driver['name'] ?? json['driverName'] ?? 'Unknown Driver';
      final String driverPhoto = driver['photoUrl'] ?? json['photoUrl'] ?? '';
      final String driverNumber = driver['mobileNumber'] ?? json['driverNumber'] ?? '';
      
      // Handle vehicle data
      final vehicle = Vehicle.fromJson(json['vehicle'] ?? {});
      
      // Handle location data
      final pickup = json['pickup'] ?? json['pickupLocation'] ?? {};
      final destination = json['destination'] ?? json['destinationLocation'] ?? {};
      
      // Extract passengers/bookings
      final List<dynamic> bookings = json['bookings'] ?? json['passengerInfo'] ?? [];
      
      // Handle price (could be int or string)
      int price = 0;
      if (json['price'] != null) {
        if (json['price'] is int) {
          price = json['price'];
        } else if (json['price'] is String) {
          price = int.tryParse(json['price']) ?? 0;
        }
      }

      // Handle status fields - could be in different formats
      String rideStatus = json['rideStatus'] ?? '';
      String passengerStatus = json['passengerStatus'] ?? json['bookingStatus'] ?? '';
      
      // Normalize status values
      if (passengerStatus.toLowerCase() == 'cancelled') {
        passengerStatus = 'Cancelled';
      } else if (passengerStatus.toLowerCase() == 'completed') {
        passengerStatus = 'Completed';
      } else if (passengerStatus.toLowerCase() == 'confirmed') {
        passengerStatus = 'Upcoming';
      }
      
      return Ride(
        id: id,
        name: driverName,
        driverPhotoUrl: driverPhoto,
        driverNumber: driverNumber,
        price: price,
        time: json['selectedTime'] ?? '',
        availableSeats: json['selectedCapacity'] ?? 0,
        vehicle: vehicle,
        pickupLocation: LocationData.fromJson(pickup),
        destinationLocation: LocationData.fromJson(destination),
        rideStatus: rideStatus,
        passengerStatus: passengerStatus,
        passengers: bookings.map((item) => Passenger.fromJson(item)).toList(),
        estimatedDistance: _parseDouble(json['estimatedDistance']),
        estimatedDuration: _parseDouble(json['estimatedDuration']),
      );
    } catch (e) {
      print('Error parsing ride: $e');
      throw FormatException('Failed to parse ride data: $e');
    }
  }
  
  // Helper method to parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class Passenger {
  final String id;
  final String status;
  final String name;
  final String photoUrl;
  final String phoneNumber;

  Passenger(
      {required this.id,
      required this.status,
      required this.name,
      required this.photoUrl,
      required this.phoneNumber});

  factory Passenger.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return Passenger(
        id: '',
        status: '',
        name: '',
        photoUrl: '',
        phoneNumber: '',
      );
    }
    
    // Check if passenger info is nested
    final Map<String, dynamic> data = json['passenger'] is Map ? json['passenger'] : json;
    
    // Get passenger ID from possible fields
    final String id = data['passengerId'] ?? data['id'] ?? data['userId'] ?? '';
    
    // Get passenger status
    final String status = data['passengerStatus'] ?? data['status'] ?? data['bookingStatus'] ?? '';
    
    return Passenger(
      id: id,
      status: status,
      name: data['passengerName'] ?? data['name'] ?? '',
      photoUrl: data['passengerPhotoUrl'] ?? data['photoUrl'] ?? '',
      phoneNumber: data['passengerNumber'] ?? data['mobileNumber'] ?? data['phoneNumber'] ?? '',
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
    if (json == null || json.isEmpty) {
      return LocationData(
        placeName: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    
    // Get location name from available fields
    final String name = json['placeName'] ?? json['name'] ?? json['address'] ?? '';
    
    // Get coordinates - handle different field names and types
    double lat = 0.0;
    if (json['latitude'] != null) {
      lat = _parseDouble(json['latitude']) ?? 0.0;
    } else if (json['lat'] != null) {
      lat = _parseDouble(json['lat']) ?? 0.0;
    }
    
    double lng = 0.0;
    if (json['longitude'] != null) {
      lng = _parseDouble(json['longitude']) ?? 0.0;
    } else if (json['lng'] != null) {
      lng = _parseDouble(json['lng']) ?? 0.0;
    }
    
    return LocationData(
      placeName: name,
      latitude: lat,
      longitude: lng,
    );
  }
  
  // Helper method to parse double values from various types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
