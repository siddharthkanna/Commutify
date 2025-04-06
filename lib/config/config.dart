import 'package:flutter_dotenv/flutter_dotenv.dart';

const apiUrl = "http://192.168.29.98:5000";

final rideUrl = "$apiUrl/ride";
final authUrl = "$apiUrl/auth";

final createUserUrl = "$authUrl/create";
final updateUserUrl = "$authUrl/user/update";
final getUserDetailsUrl = "$authUrl/user/details";

final fetchVehiclesUrl = "$authUrl/vehicles";
final addVehicleUrl = "$authUrl/vehicles/addVehicle";
final updateVehicleUrl = "$authUrl/vehicles/updateVehicle";
final deleteVehicleUrl = "$authUrl/vehicles/deleteVehicle";

final publishRideUrl = "$rideUrl/publishRide";
final fetchPublishedRidesUrl = "$rideUrl/users";
final fetchBookedRidesUrl = "$rideUrl/fetchBookedRides";
final fetchAvailableRidesUrl = "$rideUrl/fetchAvailableRides";
final bookRideUrl = "$rideUrl/bookRide";
final completeRideUrl = "$rideUrl/completeRide";
final cancelRideDriverUrl = "$rideUrl/cancelRideDriver";
final cancelRidePassengerUrl = "$rideUrl/cancelRidePassenger";

 // Base URL for user-specific endpoint