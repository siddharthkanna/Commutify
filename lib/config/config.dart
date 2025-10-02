import 'package:flutter_dotenv/flutter_dotenv.dart';


final String? apiUrl = dotenv.env['API_URL'];


final String rideUrl = "${apiUrl}/ride";
final String authUrl = "${apiUrl}/auth";

final createUserUrl = "$authUrl/create";
final updateUserUrl = "$authUrl/user/update";
final getUserDetailsUrl = "$authUrl/user/details";

final fetchVehiclesUrl = "$authUrl/vehicles";
final addVehicleUrl = "$authUrl/vehicles/add";
final updateVehicleUrl = "$authUrl/vehicles/update";
final deleteVehicleUrl = "$authUrl/vehicles/delete";


final fetchPublishedRidesUrl = "$rideUrl/driver-rides";
final fetchBookedRidesUrl = "$rideUrl/passenger-rides";
final fetchAvailableRidesUrl = "$rideUrl/fetchAvailableRides";

final publishRideUrl = "$rideUrl/publishRide";
final bookRideUrl = "$rideUrl/book";
final completeRideUrl = "$rideUrl/complete";
final cancelRideUrl = "$rideUrl/cancel";
final fetchRideStatsUrl = "$rideUrl/users"; 


