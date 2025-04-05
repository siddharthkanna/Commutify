import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/providers/auth_provider.dart';
import 'package:commutify/services/user_api.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isChangesMade = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final userData = await UserApi.getUserDetails();
    _nameController.text = userData['name'];
    _phoneNumberController.text = userData['mobileNumber'];
    _emailController.text = userData['email'];

    setState(() {
      _isChangesMade = false;
    });
  }

  void saveChanges() async {
    String newName = _nameController.text;
    String newPhoneNumber = _phoneNumberController.text;

    final auth = ref.watch(authProvider);
    final user = auth.getCurrentUser();
    user?.updateDisplayName(newName);

    bool isSuccess = await UserApi.updateUserInfo(
      newName: newName,
      newPhoneNumber: newPhoneNumber,
    );

    if (isSuccess) {
      Snackbar.showSnackbar(context, 'Details updated successfully!');

      setState(() {
        _isChangesMade = false;
      });
    } else {
      Snackbar.showSnackbar(
          context, 'Failed to update details. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Apptheme.mist,
        iconTheme: const IconThemeData(color: Apptheme.noir),
      ),
      body: Container(
        color: Apptheme.mist,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            SizedBox(height: screenHeight * 0.06),
            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildTextField(
              controller: _phoneNumberController,
              labelText: 'Phone Number',
            ),
            SizedBox(height: screenHeight * 0.04),
            emailField(
              labelText: 'Email',
              controller: _emailController,
            ),
            SizedBox(height: screenHeight * 0.08),
            Center(
              child: ElevatedButton(
                onPressed: _isChangesMade ? saveChanges : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  backgroundColor: _isChangesMade ? Apptheme.navy : Colors.grey,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Apptheme.navy,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: Apptheme.navy,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Apptheme.navy.withOpacity(0.5),
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _isChangesMade = true;
            });
          },
        ),
      ],
    );
  }

  Widget emailField({
    required String labelText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Apptheme.navy,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: Apptheme.navy,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Apptheme.navy.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
