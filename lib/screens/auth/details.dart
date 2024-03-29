import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/components/pageview.dart';
import 'package:mlritpool/providers/auth_provider.dart';
import '../../services/user_api.dart';

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DetailsPage> createState() => DetailsPageState();
}

class DetailsPageState extends ConsumerState<DetailsPage> {
  final formKey = GlobalKey<FormState>();
  String? vehicleNumber;
  String? mobileNumber;
  String? vehicleName;
  String? vehicleType;
  String? name;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final user = auth.getCurrentUser();
    name = user?.displayName;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.navy,
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
              padding: EdgeInsets.all(screenSize.width * 0.1),
              child: Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.copyWith(
                              titleMedium: const TextStyle(color: Colors.white),
                            ),
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenSize.width * 0.055,
                            horizontal: screenSize.width * 0.055,
                          ),
                          labelStyle: const TextStyle(
                            color: Apptheme.ivory,
                            fontWeight: FontWeight.normal,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenSize.width * 0.15),
                            borderSide: const BorderSide(color: Apptheme.ivory),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenSize.width * 0.15),
                            borderSide: const BorderSide(color: Apptheme.ivory),
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
                              name = value;
                            },
                          ),
                          SizedBox(height: screenSize.width * 0.08),
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
                              mobileNumber = value;
                            },
                          ),
                          SizedBox(height: screenSize.width * 0.08),
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
                              vehicleNumber = value;
                            },
                          ),
                          SizedBox(height: screenSize.width * 0.08),
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
                              vehicleName = value;
                            },
                          ),
                          SizedBox(height: screenSize.width * 0.08),
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
                              vehicleType = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.width * 0.08),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();

                          try {
                            final user =
                                ref.read(authProvider).getCurrentUser();
                            final uid = user?.uid;
                            final email = user?.email;
                            final photoUrl = user?.photoURL;
                            //final name  = user?.displayName;
                            if (name != null) {
                              await user?.updateDisplayName(name);
                            }

                            final userData = {
                              'uid': uid,
                              'email': email,
                              'name': name,
                              'mobileNumber': mobileNumber,
                              'photoUrl': photoUrl,
                              'vehicles': [
                                {
                                  'vehicleNumber': vehicleNumber,
                                  'vehicleName': vehicleName,
                                  'vehicleType': vehicleType,
                                },
                              ],
                            };

                            final success =
                                await UserApi.createUser(userData);

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
                        textStyle: TextStyle(
                          color: Apptheme.noir,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.normal,
                          fontSize: screenSize.width * 0.05,
                        ),
                        minimumSize: Size(
                            screenSize.width * 0.6, screenSize.width * 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.1),
                        ),
                        backgroundColor: Apptheme.ivory,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Apptheme.noir),
                      ),
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
