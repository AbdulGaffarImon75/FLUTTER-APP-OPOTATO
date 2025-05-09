import 'package:flutter/material.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_application_1/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPasswordFields = false;
  bool _isLoading = true;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDataSnapshot = await UserService().getUser(user.uid);
        if (userDataSnapshot.exists) {
          final userData = userDataSnapshot.data()!;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _profileImageUrl = userData['profile_image_url'];
        }
      }
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

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
      appBar: null,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color.fromARGB(
                            255,
                            191,
                            160,
                            244,
                          ),
                          backgroundImage:
                              _profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                          child:
                              (_profileImageUrl == null ||
                                      _profileImageUrl!.isEmpty)
                                  ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileField('Name', _nameController),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        'Email',
                        _emailController,
                        isEmail: true,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        'Phone Number',
                        _phoneController,
                        isPhone: true,
                      ),
                      const SizedBox(height: 24),
                      if (_showPasswordFields) ...[
                        _buildPasswordField(
                          'Current Password',
                          _currentPasswordController,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'New Password',
                          _newPasswordController,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Confirm New Password',
                          _confirmPasswordController,
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
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              191,
                              160,
                              244,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 191, 160, 244)),
            ),
          ),
          keyboardType:
              isEmail
                  ? TextInputType.emailAddress
                  : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 191, 160, 244)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
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
        final currentPass = _currentPasswordController.text.trim();
        final newPass = _newPasswordController.text.trim();
        final confirmPass = _confirmPasswordController.text.trim();

        if (newPass != confirmPass) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New passwords do not match')),
          );
          return;
        }

        final isValid = await AuthService().validateCurrentPassword(
          _emailController.text.trim(),
          currentPass,
        );

        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current password is incorrect')),
          );
          return;
        }

        await AuthService().changePassword(newPass);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }
}
