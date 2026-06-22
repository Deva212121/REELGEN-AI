import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../role_selection/role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'influencer@reelgen.ai');
  final _passwordController = TextEditingController(text: 'password123');
  String _selectedRole = 'INFLUENCER';
  bool _isLoading = false;

  void _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final service = FirebaseService();
    // Simulate real auth
    await service.login(_emailController.text, _passwordController.text, _selectedRole);
    setState(() => _isLoading = false);
    _navigateToRoleSelection();
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final service = FirebaseService();
    await service.loginWithGoogle(_selectedRole);
    setState(() => _isLoading = false);
    _navigateToRoleSelection();
  }

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF130F26), Color(0xFF07040B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Circle Area
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD0BCFF), Color(0xFFFF4B8A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD0BCFF).withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title and Taglines
                  const Text(
                    'REELGEN AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.black,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create. Promote. Track. Grow.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFC4FF62),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Credentials Container Card with Glassmorphic visual look
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0x332B2930),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: const Color(0xFF49454F), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Secure Login Console',
                          style: TextStyle(
                            color: Color(0xFFD0BCFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email Input
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Developer/User Email',
                            labelStyle: const TextStyle(color: Color(0xFF938F99)),
                            prefixIcon: const Icon(Icons.email, color: Color(0xFFD0BCFF)),
                            filled: true,
                            fillColor: const Color(0x1BFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF49454F)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Access Password',
                            labelStyle: const TextStyle(color: Color(0xFF938F99)),
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFFD0BCFF)),
                            filled: true,
                            fillColor: const Color(0x1BFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF49454F)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Assigning Initial Workplace Role Option in Login screen as requested
                        const Text(
                          'Primary Work Space Context',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleOption('INFLUENCER', 'Creator'),
                            _buildRoleOption('VENDOR', 'Merchant'),
                            _buildRoleOption('ADMIN', 'Auditor'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sign-In Button Trigger
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC4FF62),
                                  foregroundColor: Colors.black,
                                  shape: RoundedCornerShape(12),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _handleEmailLogin,
                                child: const Text(
                                  'SIGN IN AS SELECTOR',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Social Google sign-in support
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF49454F))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('OR SOCIAL FEDERATION', style: TextStyle(color: Color(0xFF938F99), fontSize: 10)),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF49454F))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF49454F), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedCornerShape(12),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFFC4FF62)),
                    label: const Text('AUTHENTICATE WITH GOOGLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String roleVal, String label) {
    final isSelected = _selectedRole == roleVal;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = roleVal;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF381E72) : const Color(0x0DFFFFFF),
            border: Border.all(
              color: isSelected ? const Color(0xFFD0BCFF) : const Color(0xFF49454F),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF938F99),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper curve constructor
RoundedCornerShape(double radius) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
