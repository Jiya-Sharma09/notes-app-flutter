import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/services/auth_service.dart';
import 'package:notes_app_flutter/screens/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String userId;
  final String email;

  const OtpScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.verifyOtp(
        widget.userId,
        _otpController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'GUESS_LOCKED_OUT':
          message =
              'Too many incorrect attempts. Please try again later.';
          break;

        case 'INCORRECT_OTP':
          message =
              'Incorrect OTP. Please check the code and try again.';
          break;

        case 'NO_VALID_OTP':
          message =
              'This OTP is no longer valid. Please request a new OTP.';
          break;

        default:
          message = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.resendOtp(widget.userId);

      if (!mounted) return;

      _startCooldown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new OTP has been sent to your email.'),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'RESEND_RATE_LIMITED':
          message =
              'Please wait before requesting another OTP.';
          break;

        default:
          message = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not resend OTP: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'We sent a verification code to',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: 'Enter 6-digit OTP',
                        counterText: '',
                      ),
                      validator: (value) {
                        final otp = value?.trim() ?? '';

                        if (otp.isEmpty) {
                          return 'Please enter the OTP';
                        }

                        if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
                          return 'OTP must be 6 digits';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    FractionallySizedBox(
                      widthFactor: 0.5,
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed:
                            authProvider.isLoading ? null : _verifyOtp,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('VERIFY OTP'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: authProvider.isLoading ||
                              _secondsRemaining > 0
                          ? null
                          : _resendOtp,
                      child: Text(
                        _secondsRemaining > 0
                            ? 'Resend OTP in ${_secondsRemaining}s'
                            : 'Resend OTP',
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

