import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/components/pageview.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _vehicleNumber;
  String? _mobileNumber;
  String? _vehicleName;
  String? _vehicleType;
 

  @override
  Widget build(BuildContext context) {
    
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(52.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
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
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _vehicleNumber = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Mobile Number'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Mobile number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _vehicleNumber = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Number'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Vehicle number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _mobileNumber = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Vehivle Name'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Vehicle Name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _mobileNumber = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Type'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Vehicle Type';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _mobileNumber = value;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    //if (_formKey.currentState?.validate() ?? false) {
                    //  _formKey.currentState?.save();
                    // TODO: Handle form submission and navigate to the main screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PageViewScreen(),
                      ),
                    );
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
    );
  }
}
