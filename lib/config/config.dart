import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['apiUrl'];

final rideUrl = "$apiUrl/ride";
final authUrl = "$apiUrl/auth";

final createUserUrl = "$authUrl/addUser";
final updateUserUrl = "$authUrl/updateUserDetails";
final getUserDetailsUrl = "$authUrl/getUserDetails";

final fetchVehiclesUrl = "$authUrl/vehicles";
final addVehicleUrl = "$authUrl/vehicles/addVehicle";
final updateVehicleUrl = "$authUrl/vehicles/updateVehicle";
final deleteVehicleUrl = "$authUrl/vehicles/deleteVehicle";

final publishRideUrl = "$rideUrl/publishRide";
final fetchPublishedRidesUrl = "$rideUrl/fetchPublishedRides";
final fetchBookedRidesUrl = "$rideUrl/fetchBookedRides";
final fetchAvailableRidesUrl = "$rideUrl/fetchAvailableRides";
final bookRideUrl = "$rideUrl/bookRide";
final completeRideUrl = "$rideUrl/completeRide";
final cancelRideDriverUrl = "$rideUrl/cancelRideDriver";
final cancelRidePassengerUrl = "$rideUrl/cancelRidePassenger";
