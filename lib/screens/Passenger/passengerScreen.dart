import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';


class Ride {
  final String pickup;
  final String destination;
  final String time;
  final double price;
  final int availableSeats;
  final String driverName;

  Ride(this.pickup, this.destination, this.time, this.price,
      this.availableSeats, this.driverName);
}

// Sample list of rides
List<Ride> rides = [
  Ride('Pickup 1', 'Destination 1', '10:00 AM', 20.0, 3, 'John Doe'),
  Ride('Pickup 2', 'Destination 2', '11:30 AM', 25.0, 2, 'Jane Smith'),
  Ride('Pickup 3', 'Destination 3', '12:45 PM', 18.0, 1, 'Mike Johnson'),
  // Add more rides here
];

class PassengerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.mist,
      appBar: AppBar(
        backgroundColor: Apptheme.mist,
        title: const Text(
          'Available Rides',
          style: TextStyle(color: Apptheme.noir, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: IconThemeData(
            color: Colors.black), // Change back button color to black
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                return RideCard(ride: rides[index]);
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Apptheme.noir,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${ride.pickup}  \u2192  ${ride.destination}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '\Rs.${ride.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.0, color: Colors.black54),
                SizedBox(width: 4.0),
                Text('${ride.time}',
                    style: TextStyle(fontSize: 14.0, color: Colors.black54)),
                Spacer(),
                Icon(Icons.event_seat, size: 16.0, color: Colors.black54),
                SizedBox(width: 4.0),
                Text('${ride.availableSeats}',
                    style: TextStyle(fontSize: 14.0, color: Colors.black54)),
              ],
            ),
            SizedBox(height: 14.0),
            const Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(
                      'https://pbs.twimg.com/profile_images/1485050791488483328/UNJ05AV8_400x400.jpg'), // Add the driver's image path here
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('John Cena',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black)),
                          Spacer(),
                          Icon(Icons.directions_car,
                              size: 16.0, color: Colors.black),
                          SizedBox(width: 4.0),
                          Text('Suzuki',
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Implement the booking functionality here
                  // For example, you can show a confirmation dialog or navigate to a booking screen.
                  // For simplicity, I'm just printing a message to the console.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'Book Ride',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
