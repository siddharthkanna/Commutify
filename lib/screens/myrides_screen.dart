import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import '../models/ride_modal.dart';
import '../services/api_service.dart';

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Ride> bookedRides = [
    Ride(
      pickup: 'Pickup 2',
      destination: 'Destination 2',
      price: 15,
      time: '10:30 AM',
      name: 'Name 1',
    ),
  ];

  List<Ride> publishedRides = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    fetchPublishedRide();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  fetchPublishedRide() async {
    final List<Ride> rides = await fetchPublishedRides();
    setState(() {
      publishedRides = rides;
      print(publishedRides);
    });
  }

  Future<void> _refreshData() async {
    await fetchPublishedRide();
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRidesList(bookedRides),
            _buildRidesList(publishedRides),
          ],
        ),
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
            '${ride.pickup.length > 15 ? ride.pickup.substring(0, 15) : ride.pickup} --> ${ride.destination.length > 15 ? ride.destination.substring(0, 15) : ride.destination}',
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
          Row(
            children: [
              const CircleAvatar(
                radius: 22.0,
                // Replace the imageProvider with your driver's image asset or network image.
                backgroundImage: NetworkImage(
                    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1600'),
              ),
              SizedBox(width: 12.0),
              Text(
                ride.name,
                style: const TextStyle(
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
