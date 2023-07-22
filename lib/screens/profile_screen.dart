import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/screens/auth/login.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authProvider);
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: Container(
        color: Apptheme.fourthColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage('assets/profile_picture.png'),
              ),
              const SizedBox(height: 24.0),
              Text(
                'User Name: ${user?.displayName ?? "N/A"}',
                style:
                    const TextStyle(fontSize: 18, color: Apptheme.primaryColor),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the edit profile screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()));
                },
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the vehicles screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VehiclesScreen()));
                },
                child: const Text('Your Vehicles'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the ride statistics screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RideStatisticsScreen()));
                },
                child: const Text('Ride Statistics'),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  authService.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Save the edited profile details
                final name = _nameController.text;
                final phoneNumber = _phoneNumberController.text;
                // Implement the logic to update the user's profile
                Navigator.pop(context); // Go back to the profile screen
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<String> vehicles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Vehicles'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return ListTile(
                  title: Text(vehicle),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String newVehicle = '';
                  return AlertDialog(
                    title: const Text('Add Vehicle'),
                    content: TextField(
                      onChanged: (value) {
                        newVehicle = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            vehicles.add(newVehicle);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}

class RideStatisticsScreen extends StatelessWidget {
  const RideStatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int ridesAsDriver = 10; // Replace with actual ride statistics
    final int ridesAsPassenger = 20; // Replace with actual ride statistics

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Statistics'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rides as Driver: $ridesAsDriver'),
          Text('Rides as Passenger: $ridesAsPassenger'),
        ],
      ),
    );
  }
}
