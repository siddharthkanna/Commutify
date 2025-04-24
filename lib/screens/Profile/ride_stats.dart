import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/controllers/ride_stats_controller.dart';
import 'package:commutify/models/ride_stats_model.dart';

class RideStatsScreen extends StatefulWidget {
  const RideStatsScreen({super.key});

  @override
  _RideStatsScreenState createState() => _RideStatsScreenState();
}

class _RideStatsScreenState extends State<RideStatsScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  RideStats? rideStats;
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    fetchRideStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchRideStats() async {
    final stats = await RideStatsController.fetchRideStats(
      context,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
    );
    
    if (stats != null) {
      setState(() {
        rideStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Ride Statistics',
          style: TextStyle(
            color: Apptheme.noir,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Apptheme.noir),
      ),
      body: isLoading
          ? const Center(child: Loader())
          : rideStats == null
              ? _buildNoStatsView()
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: fetchRideStats,
                  color: Apptheme.success,
                  child: Column(
                    children: [
                      _buildImprovedTabBar(),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedIndex = index;
                              _tabController.animateTo(index);
                            });
                          },
                          children: [
                            _buildOverviewTab(),
                            _buildDriverTab(),
                            _buildPassengerTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoStatsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 86,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No ride statistics available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start publishing or booking rides to see your stats',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: fetchRideStats,
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              _buildTabItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                title: 'Overview',
              ),
              _buildTabItem(
                index: 1,
                icon: Icons.drive_eta_rounded,
                title: 'Driver',
              ),
              _buildTabItem(
                index: 2,
                icon: Icons.airline_seat_recline_normal_rounded,
                title: 'Passenger',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _tabController.animateTo(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Apptheme.success : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSelected ? 8 : 0,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isSelected
                      ? Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildAggregateStats(),
          const SizedBox(height: 20),
          _buildTopDestinations(),
          const SizedBox(height: 20),
          _buildFinancialSummary(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Apptheme.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Apptheme.success.withOpacity(0.2),
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: Apptheme.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${rideStats!.userName}',
              style: const TextStyle(
                      fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Apptheme.noir,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s your ride journey so far',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregateStats() {
    final aggregate = rideStats!.aggregate;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_rounded, color: Apptheme.success),
                SizedBox(width: 8),
                Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Apptheme.noir,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCardImproved(
                  'Total Rides',
                  aggregate.totalRides.toString(),
                  Icons.directions_car_filled_rounded,
                  Apptheme.success,
                ),
                _buildStatCardImproved(
                  'Completed',
                  aggregate.totalRidesCompleted.toString(),
                  Icons.check_circle_rounded,
                  Colors.blue,
                ),
                _buildStatCardImproved(
                  'Distance',
                  '${aggregate.totalDistance} km',
                  Icons.route_rounded,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final aggregate = rideStats!.aggregate;
    final isPositive = aggregate.netFinancial >= 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
            child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: isPositive ? Apptheme.success : Colors.redAccent),
                const SizedBox(width: 8),
                Text(
                  'Financial Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Apptheme.noir,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'Earnings',
                    '₹${rideStats!.asDriver.totalEarnings.toStringAsFixed(2)}',
                    Icons.arrow_upward_rounded,
                    Apptheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    'Spent',
                    '₹${rideStats!.asPassenger.totalSpent.toStringAsFixed(2)}',
                    Icons.arrow_downward_rounded,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPositive ? Apptheme.success.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: isPositive ? Apptheme.success : Colors.redAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Net Balance: ₹${aggregate.netFinancial.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isPositive ? Apptheme.success : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDestinations() {
    if (rideStats?.topDestinations.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Row(
              children: [
                Icon(Icons.place_rounded, color: Apptheme.success),
                SizedBox(width: 8),
                Text(
            'Top Destinations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Apptheme.noir,
            ),
                ),
              ],
          ),
          const SizedBox(height: 16),
          ...rideStats!.topDestinations.map((destination) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Apptheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                        Icons.location_on_rounded,
                      color: Apptheme.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destination.city,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Apptheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${destination.count} rides',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Apptheme.success,
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
        ),
      ),
    );
  }

  Widget _buildStatCardImproved(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
          ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
            style: TextStyle(
            fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        ),
    );
  }

  Widget _buildDriverTab() {
    final driver = rideStats!.asDriver;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildRoleInfoCard(
            title: 'Driver Stats',
            description: 'Your activity as a ride provider', 
            icon: Icons.drive_eta_rounded,
            iconColor: Apptheme.success,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDriverStat(
                  'Total Rides Published',
                  driver.totalRidesPublished.toString(),
                    Icons.local_taxi_rounded,
                ),
                  const Divider(height: 24),
                _buildDriverStat(
                  'Completed Rides',
                  driver.totalRidesCompleted.toString(),
                    Icons.check_circle_rounded,
                ),
                  const Divider(height: 24),
                _buildDriverStat(
                  'Cancelled Rides',
                  driver.totalRidesCancelled.toString(),
                    Icons.cancel_rounded,
                ),
                  const Divider(height: 24),
                _buildDriverStat(
                  'Upcoming Rides',
                  driver.totalRidesUpcoming.toString(),
                    Icons.schedule_rounded,
                ),
                  const Divider(height: 24),
                _buildDriverStat(
                  'In-Progress Rides',
                  driver.totalRidesInProgress.toString(),
                    Icons.directions_car_rounded,
                ),
                  const Divider(height: 24),
                _buildDriverStat(
                  'Passengers Served',
                  driver.totalPassengersServed.toString(),
                    Icons.people_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Apptheme.success,
                borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Apptheme.success.withOpacity(0.3),
                  blurRadius: 10,
                    offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${driver.totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRoleInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: iconColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Apptheme.noir,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Apptheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
            icon,
            color: Apptheme.success,
            size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Apptheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
                color: Apptheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerTab() {
    final passenger = rideStats!.asPassenger;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildRoleInfoCard(
            title: 'Passenger Stats',
            description: 'Your activity as a ride taker', 
            icon: Icons.airline_seat_recline_normal_rounded,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildPassengerStat(
                  'Total Rides Booked',
                  passenger.totalRidesBooked.toString(),
                    Icons.bookmark_rounded,
                ),
                  const Divider(height: 24),
                _buildPassengerStat(
                  'Completed Rides',
                  passenger.totalRidesCompleted.toString(),
                    Icons.check_circle_rounded,
                ),
                  const Divider(height: 24),
                _buildPassengerStat(
                  'Cancelled Rides',
                  passenger.totalRidesCancelled.toString(),
                    Icons.cancel_rounded,
                ),
                  const Divider(height: 24),
                _buildPassengerStat(
                  'Upcoming Rides',
                  passenger.totalRidesUpcoming.toString(),
                    Icons.schedule_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                    offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                const Text(
                  'Total Spent',
                  style: TextStyle(
                    fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${passenger.totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPassengerStat(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
