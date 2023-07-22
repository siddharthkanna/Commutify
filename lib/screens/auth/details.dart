import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/components/pageview.dart';
import 'package:mlritpool/providers/auth_provider.dart';
import '../../services/api_service.dart';

class DetailsPage extends ConsumerWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    String? _vehicleNumber;
    String? _mobileNumber;
    String? _vehicleName;
    String? _vehicleType;
    String? _name;

    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final user = auth.getCurrentUser();

    _name = user?.displayName;

    return Scaffold(
      backgroundColor: Apptheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(52.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.copyWith(
                              titleMedium: TextStyle(
                                  color: Colors
                                      .white), // Set the text color for TextFormField
                              // Add other text styles as needed
                            ),
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 18.0,
                          ),
                          labelStyle: const TextStyle(
                            color: Apptheme.thirdColor,
                            fontWeight: FontWeight.normal,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22.0),
                            borderSide:
                                const BorderSide(color: Apptheme.fourthColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22.0),
                            borderSide:
                                const BorderSide(color: Apptheme.fourthColor),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your Name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _name = value;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Mobile Number'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your Mobile number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _mobileNumber = value;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Vehicle Number'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your Vehicle number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _vehicleNumber = value;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Vehicle Name'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your Vehicle Name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _vehicleName = value;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Vehicle Type'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your Vehicle Type';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _vehicleType = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();

                          try {
                            final user =
                                ref.read(authProvider).getCurrentUser();
                            final uid = user?.uid;
                            final email = user?.email;
                            //final name  = user?.displayName;
                            if (_name != null) {
                              await user?.updateDisplayName(_name);
                            }

                            final userData = {
                              'uid': uid,
                              'email': email,
                              'name': _name,
                              'mobileNumber': _mobileNumber,
                              'vehicles': [
                                {
                                  'vehicleNumber': _vehicleNumber,
                                  'vehicleName': _vehicleName,
                                  'vehicleType': _vehicleType,
                                },
                              ],
                            };

                            final success = await createUser(userData);

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PageViewScreen(),
                                ),
                              );
                            } else {
                              // Handle error response from the backend
                            }
                          } catch (error) {
                            // Handle error
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.normal,
                          fontSize: 18.0,
                        ),
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        backgroundColor: const Color(0xff30475e),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading) const Loader(),
        ],
      ),
    );
  }
}
