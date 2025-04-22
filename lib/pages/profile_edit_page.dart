import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_application_1/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Sabrina',
  );
  final TextEditingController _emailController = TextEditingController(
    text: '@SabrinaAry208@gmailcom',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+234 904 6470',
  );
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPasswordFields = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Center(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildProfileField('Name', _nameController),
                    _buildProfileField(
                      'Email',
                      _emailController,
                      isEmail: true,
                    ),
                    _buildProfileField(
                      'Phone Number',
                      _phoneController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 32),
                    if (_showPasswordFields) ...[
                      _buildPasswordField(
                        'Current Password',
                        _currentPasswordController,
                        isPassword: true,
                      ),
                      _buildPasswordField(
                        'New Password',
                        _newPasswordController,
                        isPassword: true,
                      ),
                      _buildPasswordField(
                        'Confirm New Password',
                        _confirmPasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showPasswordFields = !_showPasswordFields;
                          });
                        },
                        child: Text(
                          _showPasswordFields
                              ? 'Cancel Password Change'
                              : 'Change Password',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final updatedData = {
                              'name': _nameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'phone': _phoneController.text.trim(),
                            };
                            final userService = UserService();
                            await userService.updateUser(user.uid, updatedData);

                            if (_showPasswordFields) {
                              final currentPass =
                                  _currentPasswordController.text.trim();
                              final newPass =
                                  _newPasswordController.text.trim();
                              final confirmPass =
                                  _confirmPasswordController.text.trim();

                              if (newPass != confirmPass) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('New passwords do not match'),
                                  ),
                                );
                                return;
                              }

                              final isValid = await AuthService()
                                  .validateCurrentPassword(
                                    _emailController.text.trim(),
                                    currentPass,
                                  );

                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Current password is incorrect',
                                    ),
                                  ),
                                );
                                return;
                              }

                              await AuthService().changePassword(newPass);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated'),
                                ),
                              );
                            }
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom navbar
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(activeIndex: 4), // Profile icon active
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            keyboardType:
                isEmail
                    ? TextInputType.emailAddress
                    : isPhone
                    ? TextInputType.phone
                    : TextInputType.name,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
