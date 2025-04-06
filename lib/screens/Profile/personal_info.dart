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
  final TextEditingController _bioController = TextEditingController();
  
  bool _isChangesMade = false;
  bool _isLoading = false;
  String? _userRole;
  String? _photoUrl;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() => _isLoading = true);
    try {
      // Get additional user details from our API
      final userData = await UserApi.getUserDetails();

      print('User data received in personal_info.dart: $userData');
      
      // Debugging - check roles type and value
      if (userData.containsKey('roles')) {
        print('Roles type: ${userData['roles'].runtimeType}');
        print('Roles value: ${userData['roles']}');
      }
      
      // Check if we got valid user data
      if (userData.isNotEmpty) {
        _nameController.text = userData['name'] ?? '';
        _phoneNumberController.text = userData['mobileNumber'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        
        setState(() {
          _userRole = userData['roles'];
          _photoUrl = userData['photoUrl'];
          _userData = userData;
          _isChangesMade = false;
          _isLoading = false;
        });
      } else {
        // Fallback to auth provider data if API fails
        final auth = ref.watch(authProvider);
        final user = auth.getCurrentUser();
        
        // Get name from Google metadata
        String name = user?.userMetadata?['full_name'] ?? 
                     user?.userMetadata?['name'] ?? 
                     user?.email?.split('@')[0] ?? '';
        
        // Get email from auth
        String email = user?.email ?? '';
        String photoUrl = user?.userMetadata?['avatar_url'] ?? '';
        
        _nameController.text = name;
        _emailController.text = email;
        
        setState(() {
          _photoUrl = photoUrl;
          _isChangesMade = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching user details: $e');
      Snackbar.showSnackbar(context, 'Failed to load user details. Please try again.');
    }
  }

  void saveChanges() async {
    setState(() => _isLoading = true);
    
    String newName = _nameController.text;
    String newPhoneNumber = _phoneNumberController.text;
    String newBio = _bioController.text;

    try {
      bool isSuccess = await UserApi.updateUserInfo(
        newName: newName,
        newPhoneNumber: newPhoneNumber,
        newBio: newBio,
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
                  vertical: screenSize.width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    
                    SizedBox(height: screenSize.width * 0.05),
                    
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
                    
                    SizedBox(height: screenSize.width * 0.05),
                    
                    // Email field (readonly)
                    _buildInputField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      readOnly: true,
                      helperText: 'Email cannot be changed',
                    ),
                    
                    SizedBox(height: screenSize.width * 0.05),
                    
                    // Bio field
                    _buildInputField(
                      label: 'Bio',
                      controller: _bioController,
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _isChangesMade = true;
                        });
                      },
                      helperText: 'Tell others about yourself',
                    ),
                    
                    if (_userRole != null) ...[
                      SizedBox(height: screenSize.width * 0.05),
                      
                      // User Role (readonly)
                      _buildInfoField(
                        label: 'User Type',
                        value: _formatRole(_userRole),
                        icon: Icons.badge_outlined,
                      ),
                    ],
                    
                    SizedBox(height: screenSize.width * 0.08),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isChangesMade && !_isLoading ? saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Apptheme.primary,
                          foregroundColor: Apptheme.surface,
                          padding: EdgeInsets.symmetric(vertical: screenSize.width * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Apptheme.noir.withOpacity(0.1),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Apptheme.surface,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.042,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
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

  String _formatRole(String? role) {
    // Handle null or empty role
    if (role == null || role.isEmpty) {
      return 'User';
    }
    
    // If the role contains a comma, it means multiple roles
    if (role.contains(',')) {
      List<String> roles = role.split(',');
      List<String> formattedRoles = roles.map((r) => _formatSingleRole(r.trim())).toList();
      return formattedRoles.join(' & ');
    }
    
    // Otherwise, format single role
    return _formatSingleRole(role);
  }
  
  String _formatSingleRole(String role) {
    if (role == 'DRIVER') return 'Driver';
    if (role == 'PASSENGER') return 'Passenger';
    if (role == 'BOTH') return 'Driver & Passenger';
    return role;
  }
  
  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Apptheme.noir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Apptheme.mist.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Apptheme.mist.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Apptheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Apptheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Apptheme.noir.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? helperText,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Apptheme.noir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Apptheme.noir.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              color: readOnly ? Apptheme.noir.withOpacity(0.7) : Apptheme.noir,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Apptheme.primary, size: 20),
              ),
              filled: true,
              fillColor: readOnly ? Apptheme.mist.withOpacity(0.08) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              helperText: helperText,
              helperStyle: TextStyle(
                color: Apptheme.noir.withOpacity(0.5),
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Apptheme.mist.withOpacity(0.3),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Apptheme.mist.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
