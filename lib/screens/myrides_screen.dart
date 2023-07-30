import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/common/error.dart';
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

  bool isLoading = false; 

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _fetchPublishedRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPublishedRides() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Ride> rides = await ApiService.fetchPublishedRides();

      setState(() {
        publishedRides = rides;
        isLoading = false;
      });
    } catch (e) {
      Snackbar.showSnackbar(context, "Oops! Something went wrong");
      setState(() {
        publishedRides = [];
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      await _fetchPublishedRides();
    } catch (e) {
      Snackbar.showSnackbar(context, "Oops! Something went wrong");

      setState(() {
        publishedRides = [];
      });
    }
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRidesList(bookedRides, "You haven't booked any rides!"),
          _buildRidesList(publishedRides, "Oops An error has occurred!"),
        ],
      ),
    );
  }

  Future<void> fetchPublishedRides() async {
    setState(() {
      isLoading = true; // Set loading to true while fetching data
    });

    try {
      List<Ride> rides = await ApiService.fetchPublishedRides();

      setState(() {
        publishedRides = rides;
        isLoading = false; // Set loading to false after fetching data
      });
    } catch (e) {
      // Handle the error and display an error message
      setState(() {
        publishedRides = [];
        isLoading = false; // Set loading to false after handling the error
      });
    }
  }

  Widget _buildRidesList(List<Ride> rides, String emptyMessage) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (rides.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        itemCount: rides.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
        itemBuilder: (context, index) {
          return RideCard(ride: rides[index]);
        },
      ),
    );
  }
}
