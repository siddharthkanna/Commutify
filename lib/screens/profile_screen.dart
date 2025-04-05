import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/screens/Profile/personal_info.dart';
import 'package:commutify/screens/Profile/ride_stats.dart';
import 'package:commutify/screens/Profile/vehicle_details.dart';
import 'package:commutify/screens/auth/login.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authProvider);
    final user = authService.getCurrentUser();
    String image = user?.userMetadata?['avatar_url'] ?? '';
    String name = user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? 'User';
    String email = user?.email ?? '';

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.ivory,
      body: CustomScrollView(
        slivers: [
          // App Bar with profile image and gradient
          SliverAppBar(
            expandedHeight: screenSize.height * 0.3,
            floating: false,
            pinned: true,
            backgroundColor: Apptheme.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Apptheme.navy,
                          Apptheme.navy.withOpacity(0.8),
                          Apptheme.navy.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Profile image and name container
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Apptheme.ivory,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: screenSize.width * 0.15,
                          backgroundColor: Apptheme.mist,
                          backgroundImage: image.isNotEmpty
                              ? NetworkImage(image)
                              : null,
                          child: image.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: screenSize.width * 0.15,
                                  color: Apptheme.ivory,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Apptheme.ivory,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Apptheme.ivory.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Profile options
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.width * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenSize.width * 0.03,
                      bottom: screenSize.width * 0.04,
                    ),
                    child: Text(
                      'Profile Options',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Apptheme.noir,
                      ),
                    ),
                  ),
                  
                  // Personal Info Section
                  ProfileCard(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Manage your personal details',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Vehicle Details Section
                  ProfileCard(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicle Details',
                    subtitle: 'Manage your vehicles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleDetails(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ride Stats Section
                  ProfileCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Ride Statistics',
                    subtitle: 'View your ride history and stats',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideStatsScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Section title for account options
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenSize.width * 0.03,
                      bottom: screenSize.width * 0.04,
                    ),
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Apptheme.noir,
                      ),
                    ),
                  ),
                  
                  // Logout Section
                  ProfileCard(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Log out from your account',
                    iconColor: Colors.redAccent,
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Apptheme.navy),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await authService.signOut();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => Login()),
                                  );
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  
                  SizedBox(height: screenSize.width * 0.1),
                  
                  // App version at the bottom
                  Center(
                    child: Text(
                      'Commutify v1.0.0',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        color: Apptheme.noir.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.width * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom profile card widget
class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const ProfileCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Apptheme.mist.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Apptheme.mist.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Apptheme.navy,
                  size: 28,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Apptheme.noir,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Apptheme.noir.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Apptheme.noir.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
