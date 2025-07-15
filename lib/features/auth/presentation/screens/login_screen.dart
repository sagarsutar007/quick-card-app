import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/features/auth/domain/repositories/auth_repository.dart';
import 'package:quickcard/shared/widgets/labeled_text_field.dart';
import 'package:quickcard/shared/widgets/labeled_password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                const Text(
                  'Log in',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Log in to see your dashboard',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 70),

                // Dynamic Input Field (Email/Phone)
                LabeledTextField(
                  label: 'Your email or phone',
                  hintText: 'Enter email or phone number',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailOrPhoneController,
                ),
                const SizedBox(height: 16),

                LabeledPasswordField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final emailOrPhone = _emailOrPhoneController.text.trim();
                      final password = _passwordController.text.trim();

                      if (emailOrPhone.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      // try {
                      //   final authRepository = getIt<AuthRepository>();
                      //   final user = await authRepository.login(
                      //     emailOrPhone,
                      //     password,
                      //   );
                      //   debugPrint("Logged in user: ${user.name}");
                      //   if (context.mounted) {
                      //     context.go('/dashboard');
                      //   }
                      // } catch (e) {
                      //   debugPrint("Login failed: $e");
                      // } finally {
                      //   // Optional: only reset loading if login fails
                      //   if (context.mounted && _isLoading) {
                      //     setState(() {
                      //       _isLoading = false;
                      //     });
                      //   }
                      // }

                      try {
                        final authRepository = getIt<AuthRepository>();
                        final user = await authRepository.login(
                          emailOrPhone,
                          password,
                        );
                        debugPrint("Logged in user: ${user.name}");
                        if (context.mounted) {
                          context.go('/dashboard');
                        }
                      } catch (e) {
                        debugPrint("Login failed: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted && _isLoading) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy Policy
                const Center(
                  child: Text(
                    'For more information, please see our Privacy Policy.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
