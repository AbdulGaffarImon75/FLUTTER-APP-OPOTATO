import 'package:flutter/material.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../models/user_model.dart';
import 'bottom_nav_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController _ctrl = EditProfileController();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _showPasswordFields = false;
  bool _loading = true;
  String? _profileImageUrl;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _ctrl.fetchUser();
    if (user == null) {
      Navigator.pop(context);
      return;
    }
    _user = user;
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phone;
    _profileImageUrl = user.profileImageUrl;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    // Update profile fields
    await _ctrl.updateProfile(
      uid: _user.uid,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    // Handle password change if requested
    if (_showPasswordFields) {
      if (_newPassCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        setState(() => _loading = false);
        return;
      }
      final ok = await _ctrl.changePassword(
        email: _emailCtrl.text.trim(),
        currentPassword: _currentPassCtrl.text.trim(),
        newPassword: _newPassCtrl.text.trim(),
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
        setState(() => _loading = false);
        return;
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImageUrl?.isNotEmpty == true
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                  child:
                      _profileImageUrl?.isEmpty == true
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildField('Name', _nameCtrl),
              const SizedBox(height: 16),
              _buildField('Email', _emailCtrl, isEmail: true),
              const SizedBox(height: 16),
              _buildField('Phone', _phoneCtrl, isPhone: true),
              const SizedBox(height: 24),
              if (_showPasswordFields) ...[
                _buildPasswordField('Current Password', _currentPassCtrl),
                const SizedBox(height: 16),
                _buildPasswordField('New Password', _newPassCtrl),
                const SizedBox(height: 16),
                _buildPasswordField('Confirm Password', _confirmPassCtrl),
                const SizedBox(height: 16),
              ],
              Center(
                child: TextButton(
                  onPressed:
                      () => setState(
                        () => _showPasswordFields = !_showPasswordFields,
                      ),
                  child: Text(
                    _showPasswordFields
                        ? 'Cancel Password Change'
                        : 'Change Password',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType:
              isEmail
                  ? TextInputType.emailAddress
                  : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
