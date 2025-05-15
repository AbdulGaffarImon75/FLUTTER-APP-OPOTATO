import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import '../pages/signup_page.dart';
import '../pages/profile_page.dart';
import '../pages/bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _ctrl = LoginController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final user = await _ctrl.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
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
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'OPotato',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildField('Email', _emailCtrl, TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField(
                'Password',
                _passwordCtrl,
                TextInputType.text,
                obscure: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController ctrl,
    TextInputType t, {
    bool obscure = false,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: t,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
