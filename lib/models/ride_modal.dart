import 'package:mlritpool/models/vehicle_modal.dart';

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
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['rideId'] ?? '',
      name: json['driverName'] ?? 'No Name',
      driverPhotoUrl: json['photoUrl'] ?? '',
      driverNumber: json['driverNumber'] ?? '',
      price: json['price'] ?? 0,
      time: json['selectedTime'] ?? '',
      availableSeats: json['selectedCapacity'] ?? 0,
      vehicle: Vehicle.fromJson(json['vehicle']),
      destinationLocation: LocationData.fromJson(json['destinationLocation']),
      pickupLocation: LocationData.fromJson(json['pickupLocation']),
      rideStatus: json['rideStatus'] ?? '',
      passengerStatus: json['passengerStatus'] ?? '',
      passengers: List<Passenger>.from(json['passengerInfo']
              ?.map((passenger) => Passenger.fromJson(passenger)) ??
          []),
    );
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
    return Passenger(
      id: json['passengerId'] ?? '',
      status: json['passengerStatus'] ?? '',
      name: json['passengerName'] ?? '',
      photoUrl: json['passengerPhotoUrl'] ?? '',
      phoneNumber: json['passengerNumber'] ?? '',
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
