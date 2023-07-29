import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import '../models/ride_modal.dart';
import 'ride_card.dart';
import '../services/api_service.dart';

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Ride> bookedRides = [];

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
    List<Ride> rides = await ApiService.fetchPublishedRides();

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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.mist,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(
              left: screenSize.width * 0.04, top: screenSize.width * 0.04),
          child: const Text(
            'My Rides',
            style: TextStyle(
                color: Apptheme.noir,
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
        backgroundColor: Apptheme.mist,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Apptheme.noir,
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
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      itemCount: rides.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
      itemBuilder: (context, index) {
        return RideCard(ride: rides[index]);
      },
    );
  }
}
