import 'package:flutter_dotenv/flutter_dotenv.dart';

const apiUrl = "http://192.168.29.98:5000";

const rideUrl = "$apiUrl/ride";
const authUrl = "$apiUrl/auth";

const createUserUrl = "$authUrl/create";
const updateUserUrl = "$authUrl/user/update";
const getUserDetailsUrl = "$authUrl/user/details";

const fetchVehiclesUrl = "$authUrl/vehicles";
const addVehicleUrl = "$authUrl/vehicles/addVehicle";
const updateVehicleUrl = "$authUrl/vehicles/updateVehicle";
const deleteVehicleUrl = "$authUrl/vehicles/deleteVehicle";

const publishRideUrl = "$rideUrl/publishRide";
const fetchPublishedRidesUrl = "$rideUrl/users";
const fetchAvailableRidesUrl = "$rideUrl/fetchAvailableRides";
const bookRideUrl = "$rideUrl/bookRide";
const completeRideUrl = "$rideUrl/rides";
const cancelRideDriverUrl = "$rideUrl/cancelRideDriver";
const cancelRidePassengerUrl = "$rideUrl/cancelRidePassenger";
const cancelRideUrl = "$rideUrl/rides";
const fetchRideStatsUrl = "$rideUrl/users"; // For endpoint /ride/users/:userId/ride-stats


