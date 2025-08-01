import 'package:flutter/material.dart';
import '../../controllers/signup_controller.dart';
import '../pages/profile_page.dart';
import '../pages/bottom_nav_bar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SignupController _ctrl = SignupController();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String? _userType;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
      _imageUrlCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (_userType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a user type')));
      return;
    }

    final user = await _ctrl.signup(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      userType: _userType!,
      profileImageUrl: _imageUrlCtrl.text,
    );

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
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
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'OPotato',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Create an account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Customer or Restaurant?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Customer'),
                        value: 'customer',
                        groupValue: _userType,
                        onChanged: (v) => setState(() => _userType = v),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Restaurant'),
                        value: 'restaurant',
                        groupValue: _userType,
                        onChanged: (v) => setState(() => _userType = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField('Name', _nameCtrl, TextInputType.name),
                const SizedBox(height: 16),
                _buildField('Phone', _phoneCtrl, TextInputType.phone),
                const SizedBox(height: 16),
                _buildField('Email', _emailCtrl, TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(
                  'Password',
                  _passwordCtrl,
                  TextInputType.text,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _buildField(
                  'Confirm Password',
                  _confirmCtrl,
                  TextInputType.text,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _buildField(
                  'Profile Image URL (optional)',
                  _imageUrlCtrl,
                  TextInputType.url,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Sign up'),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    TextInputType type, {
    bool obscure = false,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: type,
    decoration: InputDecoration(
      hintText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
