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
  String? _rollNo;
  String? _vehicleNumber;
  String? _mobileNumber;
  String? _selectedBranch;
  String? _selectedYear;

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
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.0),
                        borderSide: const BorderSide(color: Apptheme.fourthColor),
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Branch'),
                        value: _selectedBranch,
                        items: ['CSE', 'ECE', 'IT','CSIT','CSM','CSC','CSD','MECH','AERO'] // Replace with your branch options
                            .map((branch) => DropdownMenuItem<String>(
                                  value: branch,
                                  child: Text(branch),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value as String;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your branch';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Year'),
                        value: _selectedYear,
                        items: ['I Year', 'II Year', 'III Year','IV Year'] // Replace with your year options
                            .map((year) => DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value as String;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Roll Number'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your roll number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _rollNo = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Vehicle Number'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your vehicle number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _vehicleNumber = value;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your mobile number';
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
                      fontWeight: FontWeight.bold,
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
