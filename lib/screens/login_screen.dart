import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Focus nodes to detect when a field is clicked/active
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  final Color _fluorescentGreen = const Color(0xFF9CFF00);

  @override
  void initState() {
    super.initState();
    // Rebuild UI when focus changes to update border colors
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // ... (Your existing login logic remains the same)
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F10),
      body: Stack(
        children: [
          // Background "Glow" blobs for better glass effect contrast
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fluorescentGreen.withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      // 2. Fluorescent green outline for the card
                      border: Border.all(
                        color: _fluorescentGreen.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/unifound_logo.png', height: 80),
                          const SizedBox(height: 32),
                          _field(_emailController, 'University Email', 
                                 Icons.email_outlined, false, _emailFocus),
                          const SizedBox(height: 20),
                          _field(_passwordController, 'Password', 
                                 Icons.lock_outline, true, _passwordFocus),
                          const SizedBox(height: 32),
                          // 4. Smaller width sign-in button
                          Center(child: _loginButton()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, bool o, FocusNode f) {
    bool isFocused = f.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l,
          style: TextStyle(
            color: isFocused ? _fluorescentGreen : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            // 3. Fluorescent green outline when field is clicked
            border: Border.all(
              color: isFocused 
                  ? _fluorescentGreen 
                  : Colors.white.withValues(alpha: 0.1),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused ? [
              BoxShadow(
                color: _fluorescentGreen.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: TextFormField(
            controller: c,
            focusNode: f,
            obscureText: o,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(i, 
                color: isFocused ? _fluorescentGreen : Colors.white24, 
                size: 20
              ),
              border: InputBorder.none,
              hintText: 'Enter $l',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return SizedBox(
      height: 50,
      width: 180, // 4. Smaller width
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _fluorescentGreen,
          foregroundColor: Colors.black,
          elevation: 10,
          shadowColor: _fluorescentGreen.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
      ),
    );
  }
}