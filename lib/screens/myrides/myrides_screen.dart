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
      if (mounted) {
        Snackbar.showSnackbar(context, "Oops! Something went wrong");
      }
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
      if (mounted) {
        // Check if the error is due to a connection issue (SocketException)
        if (e is SocketException) {
          Snackbar.showSnackbar(
              context, "Connection error. Please try again later.");
        } else {
          Snackbar.showSnackbar(context, "Oops! Something went wrong");
        }
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
      if (mounted) {
        Snackbar.showSnackbar(context, "Oops! Something went wrong");
      }

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
      backgroundColor: Apptheme.ivory,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Apptheme.navy,
        iconTheme: const IconThemeData(color: Apptheme.ivory),
        title: Text(
          'My Rides',
          style: TextStyle(
            color: Apptheme.ivory,
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width * 0.06,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Apptheme.ivory,
          indicatorWeight: 3,
          labelColor: Apptheme.ivory,
          unselectedLabelColor: Apptheme.ivory.withOpacity(0.7),
          labelStyle: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              text: 'Booked', 
              icon: Icon(Icons.airline_seat_recline_normal),
            ),
            Tab(
              text: 'Published',
              icon: Icon(Icons.drive_eta),
            ),
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

  Widget _buildRidesList(List<Ride> rides, String emptyMessage,
      {required bool isPublished}) {
    final screenSize = MediaQuery.of(context).size;
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Apptheme.navy),
      );
    }

    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPublished ? Icons.drive_eta_outlined : Icons.airline_seat_recline_normal_outlined,
              size: screenSize.width * 0.2,
              color: Apptheme.mist.withOpacity(0.8),
            ),
            SizedBox(height: screenSize.width * 0.04),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.w600,
                color: Apptheme.noir,
              ),
            ),
            SizedBox(height: screenSize.width * 0.02),
            Text(
              isPublished 
                ? "Publish a ride to see it here"
                : "Book a ride to see it here",
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                color: Apptheme.noir.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Apptheme.navy,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(screenSize.width * 0.04),
        itemCount: rides.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: screenSize.width * 0.03),
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
                ).then((_) => _refreshData());
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
                ).then((_) => _refreshData());
              },
              child: BookedCard(ride: rides[index]),
            );
          }
        }
      ),
    );
  }
}
