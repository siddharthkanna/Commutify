import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/components/pageview.dart';
import 'package:commutify/providers/auth_provider.dart';
import '../../services/user_api.dart';

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DetailsPage> createState() => DetailsPageState();
}

enum UserRole { passenger, driver, both }

class DetailsPageState extends ConsumerState<DetailsPage> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? mobileNumber;
  
  // Vehicle details
  String? vehicleNumber;
  String? vehicleName;
  String? vehicleType;
  int vehicleCapacity = 4;
  String? vehicleColor;
  String? vehicleMake;
  String? vehicleModel;
  int? vehicleYear;
  
  // Role selection
  UserRole selectedRole = UserRole.passenger;
  bool showVehicleDetails = false;
  bool isFormSubmitting = false;
  
  // Track current step
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    // Initialize based on role
    updateShowVehicleDetails();
  }
  
  void updateShowVehicleDetails() {
    setState(() {
      showVehicleDetails = selectedRole == UserRole.driver || selectedRole == UserRole.both;
    });
  }

  String getRoleString(UserRole role) {
    switch(role) {
      case UserRole.passenger:
        return 'PASSENGER';
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.both:
        return 'BOTH';
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      // If passenger only, directly submit the form
      if (selectedRole == UserRole.passenger) {
        _submitForm();
      } else {
        setState(() {
          _currentStep += 1;
        });
      }
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final user = auth.getCurrentUser();
    
    // Pre-fill name if available from Google sign-in
    name ??= user?.userMetadata?['full_name'] as String?;
    
    return Scaffold(
      backgroundColor: Apptheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Apptheme.primary,
                    Color.lerp(Apptheme.primary, Apptheme.secondary, 0.15)!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      children: [
                        Text(
                          _currentStep == 0 ? 'Complete Your Profile' : 'Vehicle Details',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Apptheme.surface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentStep == 0 
                            ? 'Tell us a little about yourself'
                            : 'Add your vehicle information',
                          style: TextStyle(
                            fontSize: 16,
                            color: Apptheme.surface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicator - only show if user is driver or both
                  if (showVehicleDetails)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Apptheme.surface,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentStep >= 1 
                                  ? Apptheme.surface 
                                  : Apptheme.surface.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                  
                  // Form content
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _currentStep == 0 
                          ? _buildBasicInfoForm()
                          : _buildVehicleDetailsForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Apptheme.primary.withOpacity(0),
                      Apptheme.primary.withOpacity(0.8),
                      Apptheme.primary,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        style: TextButton.styleFrom(
                          foregroundColor: Apptheme.surface.withOpacity(0.7),
                        ),
                        child: const Text('BACK'),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Apptheme.surface,
                        foregroundColor: Apptheme.noir,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep < 1 
                          ? (selectedRole == UserRole.passenger ? 'FINISH' : 'NEXT')
                          : 'FINISH',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Loading overlay
            if (loading) const LoaderAnimated(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        _buildInputLabel('Full Name'),
        const SizedBox(height: 8),
        _buildTextField(
          initialValue: name,
          prefixIcon: Icons.person_outline,
          hint: 'John Doe',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your name';
            }
            return null;
          },
          onSaved: (value) {
            name = value;
          },
        ),
        const SizedBox(height: 24),
        
        // Mobile field
        _buildInputLabel('Mobile Number'),
        const SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Icons.phone_outlined,
          hint: '+1 555 123 4567',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your mobile number';
            }
            return null;
          },
          onSaved: (value) {
            mobileNumber = value;
          },
        ),
        const SizedBox(height: 36),
        
        // Role selection
        _buildInputLabel('How will you use Commutify?'),
        const SizedBox(height: 12),
        _buildRoleSelector(),
      ],
    );
  }
  
  Widget _buildVehicleDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle number
        _buildInputLabel('Vehicle Number'),
        const SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Icons.numbers_outlined,
          hint: 'AB1234CD',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your vehicle number';
            }
            return null;
          },
          onSaved: (value) {
            vehicleNumber = value;
          },
        ),
        const SizedBox(height: 24),
        
        // Vehicle name
        _buildInputLabel('Vehicle Name'),
        const SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Icons.drive_file_rename_outline,
          hint: 'My Car',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your vehicle name';
            }
            return null;
          },
          onSaved: (value) {
            vehicleName = value;
          },
        ),
        const SizedBox(height: 24),
        
        // Vehicle type
        _buildInputLabel('Vehicle Type'),
        const SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Icons.directions_car_outlined,
          hint: 'Sedan, SUV, Hatchback',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your vehicle type';
            }
            return null;
          },
          onSaved: (value) {
            vehicleType = value;
          },
        ),
        const SizedBox(height: 24),
        
        // Two fields in a row
        Row(
          children: [
            // Capacity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Capacity'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    initialValue: '4',
                    prefixIcon: Icons.people_outline,
                    hint: '4',
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      vehicleCapacity = int.tryParse(value ?? '4') ?? 4;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Color
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Color'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    prefixIcon: Icons.color_lens_outlined,
                    hint: 'Black',
                    onSaved: (value) {
                      vehicleColor = value;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Another two fields in a row
        Row(
          children: [
            // Make
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Make'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    prefixIcon: Icons.factory_outlined,
                    hint: 'Honda, Toyota',
                    onSaved: (value) {
                      vehicleMake = value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Model
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Model'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    prefixIcon: Icons.model_training,
                    hint: 'Civic, Corolla',
                    onSaved: (value) {
                      vehicleModel = value;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Year
        _buildInputLabel('Year'),
        const SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Icons.date_range_outlined,
          hint: '2023',
          keyboardType: TextInputType.number,
          onSaved: (value) {
            if (value != null && value.isNotEmpty) {
              vehicleYear = int.tryParse(value);
            }
          },
        ),
        const SizedBox(height: 80), // Extra space for the bottom button
      ],
    );
  }
  
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Apptheme.surface,
      ),
    );
  }
  
  Widget _buildTextField({
    String? initialValue,
    required IconData prefixIcon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Apptheme.surface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Apptheme.surface.withOpacity(0.5)),
        prefixIcon: Icon(prefixIcon, color: Apptheme.surface),
        filled: true,
        fillColor: Apptheme.secondary.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }
  
  Widget _buildRoleSelector() {
    return Column(
      children: [
        _buildRoleOption(
          UserRole.passenger,
          'Passenger',
          'Find rides with others going your way',
          Icons.commute_outlined
        ),
        const SizedBox(height: 8),
        _buildRoleOption(
          UserRole.driver, 
          'Driver', 
          'Offer rides and share travel costs',
          Icons.drive_eta_outlined
        ),
        const SizedBox(height: 8),
        _buildRoleOption(
          UserRole.both, 
          'Both', 
          'Find and offer rides as needed',
          Icons.swap_horiz_outlined
        ),
      ],
    );
  }
  
  Widget _buildRoleOption(UserRole role, String title, String description, IconData icon) {
    final isSelected = selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
          updateShowVehicleDetails();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? Apptheme.secondary.withOpacity(0.2) 
            : Apptheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Apptheme.surface 
              : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Apptheme.surface
                  : Apptheme.surface.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected 
                  ? Apptheme.primary 
                  : Apptheme.surface,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w500,
                      color: Apptheme.surface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Apptheme.surface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio<UserRole>(
              value: role,
              groupValue: selectedRole,
              onChanged: (UserRole? value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                    updateShowVehicleDetails();
                  });
                }
              },
              fillColor: WidgetStateProperty.all(Apptheme.surface),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _submitForm() async {
    // Validate current step
    if (_currentStep == 0) {
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }
      
      // If user selected driver or both, go to next step
      if (showVehicleDetails && _currentStep == 0) {
        setState(() {
          _currentStep = 1;
        });
        return;
      }
    }
    
    // Final validation before submission
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      
      final auth = ref.read(authProvider);
      auth.setLoading(true);
      auth.setError('');
      
      try {
        final user = auth.getCurrentUser();
        if (user == null) {
          auth.setError('No authenticated user found');
          return;
        }
        
        final uid = user.id;
        final email = user.email;
        final photoUrl = user.userMetadata?['avatar_url'];
        
        // Prepare request data
        final Map<String, dynamic> requestData = {
          'uid': uid,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'mobileNumber': mobileNumber,
          'role': getRoleString(selectedRole),
        };
        
        // Add vehicle details if user selected to be a driver or both
        if (showVehicleDetails && vehicleNumber != null && vehicleName != null && vehicleType != null) {
          requestData['vehicle'] = {
            'vehicleNumber': vehicleNumber,
            'vehicleName': vehicleName,
            'vehicleType': vehicleType,
            'capacity': vehicleCapacity,
            'color': vehicleColor,
            'make': vehicleMake,
            'model': vehicleModel,
            'year': vehicleYear,
          };
        }
        
        // Create user using the new API endpoint
        final success = await UserApi.createNewUser(requestData);
        
        if (success) {
          if (!mounted) return;
          
          // Navigate to the main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PageViewScreen(),
            ),
          );
        } else {
          auth.setError('Failed to create user. Please try again.');
        }
      } catch (error) {
        auth.setError('Error: $error');
      } finally {
        auth.setLoading(false);
      }
    }
  }
}
