import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Ride> bookedRides = [
    Ride(
      pickup: 'Pickup 1',
      destination: 'Destination 1',
      price: 10.0,
      time: '9:00 AM',
    ),
    Ride(
      pickup: 'Pickup 2',
      destination: 'Destination 2',
      price: 15.0,
      time: '10:30 AM',
    ),
  ];

  final List<Ride> publishedRides = [
    Ride(
      pickup: 'Pickup 3',
      destination: 'Destination 3',
      price: 20.0,
      time: '12:00 PM',
    ),
    Ride(
      pickup: 'Pickup 4',
      destination: 'Destination 4',
      price: 25.0,
      time: '2:30 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.fourthColor,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 10.0, top: 10.0),
          child: const Text(
            'My Rides',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Apptheme.fourthColor,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: 'Booked'),
            Tab(text: 'Published'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRidesList(bookedRides),
          _buildRidesList(publishedRides),
        ],
      ),
    );
  }

  Widget _buildRidesList(List<Ride> rides) {
    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: rides.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        return RideCard(ride: rides[index]);
      },
    );
  }
}

class Ride {
  final String pickup;
  final String destination;
  final double price;
  final String time;

  Ride({
    required this.pickup,
    required this.destination,
    required this.price,
    required this.time,
  });
}

class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.fourthColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes the shadow direction
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Text(
            '${ride.pickup} --> ${ride.destination}',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            '\$${ride.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 16.0),
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 16.0),
              SizedBox(width: 4.0),
              Text(
                '12th October',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16.0),
              const SizedBox(width: 4.0),
              Text(
                '${ride.time}',
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          const Row(
            children: [
              Icon(Icons.people, size: 16.0),
              SizedBox(width: 4.0),
              Text(
                '2',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Row(
            children: [
              CircleAvatar(
                radius: 22.0,
                // Replace the imageProvider with your driver's image asset or network image.
                backgroundImage: AssetImage('assets/driver_avatar.png'),
              ),
              SizedBox(width: 12.0),
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
