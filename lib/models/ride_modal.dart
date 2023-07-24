class Ride {
  final String pickup;
  final String destination;
  final int price;
  final String time;
  final String name;

  Ride(
      {required this.pickup,
      required this.destination,
      required this.price,
      required this.time,
      required this.name});

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      name: json['driverName'] ?? 'No Name',
      pickup: json['pickupLocationName'] ?? '',
      destination: json['destinationLocationName'] ?? '',
      price: json['price'] ?? 0.0,
      time: json['selectedTime'] ?? '',
    );
  }
}
