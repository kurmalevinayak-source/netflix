import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _usePhone = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (_usePhone) {
        if (!auth.isOtpSent) {
          await auth.sendOTP(_phoneController.text.trim());
        } else {
          final error = await auth.verifyOTP(_otpController.text.trim());
          if (error != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: AppTheme.primaryRed),
            );
          }
        }
      } else {
        final error = await auth.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.primaryRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.red.withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimalist Logo
                  const Text(
                    'NETFLIX',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  
                  if (!_usePhone) ...[
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: _buildInputDecoration('Email'),
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: _buildInputDecoration('Password'),
                      validator: (value) => value!.length < 6 ? 'Too short' : null,
                    ),
                  ] else ...[
                    if (!auth.isOtpSent)
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration('Phone Number (+123...)'),
                        validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                      )
                    else
                      TextFormField(
                        controller: _otpController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Enter 6-digit OTP'),
                        validator: (value) => value!.isEmpty ? 'Enter OTP' : null,
                      ),
                  ],
                  
                  const SizedBox(height: 25),
                  
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: auth.isLoading
                        ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                        : Text(
                            _usePhone ? (auth.isOtpSent ? 'VERIFY' : 'SEND OTP') : 'SIGN IN',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Simplified Toggle
                  TextButton(
                    onPressed: () => setState(() => _usePhone = !_usePhone),
                    child: Text(
                      _usePhone ? 'Sign in with Email' : 'Sign in with Phone',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  const Divider(color: Colors.white24, height: 40),
                  
                  // Skip as Guest (no Firebase account required)
                  OutlinedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .enterGuestMode();
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('SKIP AS GUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: const Text(
                      'New to Netflix? Sign up now.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.white30)),
    );
  }
}
