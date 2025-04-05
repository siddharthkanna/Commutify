import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/providers/auth_provider.dart';
import 'package:commutify/services/user_api.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isChangesMade = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() => _isLoading = true);
    try {
      final userData = await UserApi.getUserDetails();
      _nameController.text = userData['name'];
      _phoneNumberController.text = userData['mobileNumber'];
      _emailController.text = userData['email'];

      setState(() {
        _isChangesMade = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Snackbar.showSnackbar(context, 'Failed to load user details. Please try again.');
    }
  }

  void saveChanges() async {
    setState(() => _isLoading = true);
    
    String newName = _nameController.text;
    String newPhoneNumber = _phoneNumberController.text;

    final auth = ref.watch(authProvider);
    final user = auth.getCurrentUser();

    try {
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
    } catch (e) {
      Snackbar.showSnackbar(
          context, 'An error occurred. Please try again later.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Apptheme.primary,
        iconTheme: const IconThemeData(color: Apptheme.surface),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Apptheme.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Save icon button in app bar
          _isChangesMade
              ? IconButton(
                  icon: const Icon(Icons.check, color: Apptheme.surface),
                  onPressed: _isLoading ? null : saveChanges,
                  tooltip: 'Save changes',
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Apptheme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                  vertical: screenSize.width * 0.08,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture section
                    Center(
                      child: Column(
                        children: [
                          // User avatar (can be enhanced later with image uploading)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Apptheme.primary,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: screenSize.width * 0.15,
                              backgroundColor: Apptheme.mist.withOpacity(0.5),
                              child: Icon(
                                Icons.person,
                                size: screenSize.width * 0.15,
                                color: Apptheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.width * 0.04),
                          
                          // Future feature note
                          Text(
                            'Profile picture management coming soon',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.035,
                              color: Apptheme.noir.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: screenSize.width * 0.1),
                    
                    // Form fields section
                    Text(
                      'Your Details',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Apptheme.noir,
                      ),
                    ),
                    SizedBox(height: screenSize.width * 0.05),
                    
                    // Name field
                    _buildInputField(
                      label: 'Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      onChanged: (value) {
                        setState(() {
                          _isChangesMade = true;
                        });
                      },
                    ),
                    
                    SizedBox(height: screenSize.width * 0.06),
                    
                    // Phone number field
                    _buildInputField(
                      label: 'Phone Number',
                      controller: _phoneNumberController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _isChangesMade = true;
                        });
                      },
                    ),
                    
                    SizedBox(height: screenSize.width * 0.06),
                    
                    // Email field (readonly)
                    _buildInputField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      readOnly: true,
                      helperText: 'Email cannot be changed',
                    ),
                    
                    SizedBox(height: screenSize.width * 0.1),
                    
                    // Save button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isChangesMade && !_isLoading ? saveChanges : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Apptheme.primary,
                            foregroundColor: Apptheme.surface,
                            padding: EdgeInsets.symmetric(vertical: screenSize.width * 0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Apptheme.mist,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Apptheme.surface,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? helperText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Apptheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: Apptheme.primary.withOpacity(0.7),
              size: 22,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 12,
              color: Apptheme.noir.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Apptheme.mist.withOpacity(0.8),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Apptheme.mist.withOpacity(0.8),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Apptheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Apptheme.noir,
          ),
        ),
      ],
    );
  }
}
