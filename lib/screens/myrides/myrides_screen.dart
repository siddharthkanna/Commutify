import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/screens/myrides/booked_card.dart';
import 'package:commutify/screens/myrides/ride_details_booked.dart.dart';
import 'package:commutify/screens/myrides/ride_details_published.dart';
import 'package:commutify/services/ride_api.dart';
import '../../models/ride_modal.dart';
import 'published_card.dart';
import '../../services/user_api.dart';
import 'dart:io';

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Ride> bookedRides = [];
  List<Ride> publishedRides = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bookedRides();
    _publishedRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _publishedRides() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Ride> rides = await RideApi.fetchPublishedRides();

      setState(() {
        publishedRides = rides;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Snackbar.showSnackbar(context, "Oops! Something went wrong");
    }
  }

  Future<void> _bookedRides() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Ride> rides = await RideApi.fetchBookedRides();

      setState(() {
        bookedRides = rides;
        isLoading = false;
      });
    } catch (e) {
      // Check if the error is due to a connection issue (SocketException)
      if (e is SocketException) {
        Snackbar.showSnackbar(
            context, "Connection error. Please try again later.");
      } else {
        Snackbar.showSnackbar(context, "Oops! Something went wrong");
      }

      setState(() {
        bookedRides = [];
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      await _bookedRides();
      await _publishedRides();
    } catch (e) {
      Snackbar.showSnackbar(context, "Oops! Something went wrong");

      setState(() {
        publishedRides = [];
        bookedRides = [];
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
          _buildRidesList(bookedRides, "You haven't booked any rides!",
              isPublished: false),
          _buildRidesList(publishedRides, "You haven't published any rides!",
              isPublished: true),
        ],
      ),
    );
  }

  Future<void> fetchPublishedRides() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Ride> rides = await RideApi.fetchPublishedRides();

      setState(() {
        publishedRides = rides;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        publishedRides = [];
        isLoading = false;
      });
    }
  }

  Widget _buildRidesList(List<Ride> rides, String emptyMessage,
      {required bool isPublished}) {
    if (isLoading) {
      return const Center(
        child: Loader(),
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
            if (isPublished) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RideDetailsPublished(ride: rides[index]),
                    ),
                  );
                },
                child: PublishedCard(ride: rides[index]),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RideDetailsBooked(ride: rides[index]),
                    ),
                  );
                },
                child: BookedCard(ride: rides[index]),
              );
            }
          }),
    );
  }
}
