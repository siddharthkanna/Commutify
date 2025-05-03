import 'package:flutter_dotenv/flutter_dotenv.dart';

const apiUrl = "http://192.168.29.98:5000";
//const apiUrl = "https://commutify-backend.onrender.com";

const rideUrl = "$apiUrl/ride";
const authUrl = "$apiUrl/auth";

const createUserUrl = "$authUrl/create";
const updateUserUrl = "$authUrl/user/update";
const getUserDetailsUrl = "$authUrl/user/details";

const fetchVehiclesUrl = "$authUrl/vehicles";
const addVehicleUrl = "$authUrl/vehicles/add";
const updateVehicleUrl = "$authUrl/vehicles/update";
const deleteVehicleUrl = "$authUrl/vehicles/delete";


const fetchPublishedRidesUrl = "$rideUrl/driver-rides";
const fetchBookedRidesUrl = "$rideUrl/passenger-rides";
const fetchAvailableRidesUrl = "$rideUrl/fetchAvailableRides";

const publishRideUrl = "$rideUrl/publishRide";
const bookRideUrl = "$rideUrl/book";
const completeRideUrl = "$rideUrl/complete";
const cancelRideUrl = "$rideUrl/cancel";
const fetchRideStatsUrl = "$rideUrl/users"; 


