import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import './widgets/auth_form_widget.dart';
import './widgets/social_login_widget.dart';
import './widgets/terms_privacy_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((data) {
      // Remove undefined AuthChangeEvent usage
      if (data.event == 'signedIn') {
        _navigateToHome();
      }
    });
  }

  void _onTabChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    _tabController.animateTo(index);
  }

  void _handleAuthentication(
      bool isSignUp, Map<String, String> formData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (isSignUp) {
        final response = await _authService.signUp(
          email: formData['email']!,
          password: formData['password']!,
          fullName: formData['name']!,
        );

        if (response.user != null) {
          if (response.user!.emailConfirmedAt != null) {
            _showSuccessAndNavigate('Account created successfully!');
          } else {
            _showSuccessMessage(
                'Please check your email to confirm your account.');
          }
        }
      } else {
        final response = await _authService.signIn(
          email: formData['email']!,
          password: formData['password']!,
        );

        if (response.user != null) {
          _showSuccessAndNavigate('Welcome back!');
        }
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please confirm your email address before signing in.';
      } else if (e.toString().contains('User already registered')) {
        errorMessage =
            'This email is already registered. Please sign in instead.';
      }

      _showErrorMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessAndNavigate(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to home dashboard after successful authentication
    Future.delayed(const Duration(milliseconds: 1500), () {
      _navigateToHome();
    });
  }

  void _showSuccessMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home-dashboard');
  }

  void _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      if (provider == 'Google') {
        success = await _authService.signInWithGoogle();
      } else if (provider == 'Apple') {
        success = await _authService.signInWithApple();
      }

      if (success) {
        _showSuccessAndNavigate('Signed in with $provider successfully!');
      } else {
        _showErrorMessage('$provider sign-in was cancelled.');
      }
    } catch (e) {
      _showErrorMessage('$provider sign-in failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleForgotPassword() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we will send you a link to reset your password.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && _authService.isValidEmail(email)) {
                try {
                  await _authService.resetPassword(email: email);
                  Navigator.pop(context);
                  _showSuccessMessage(
                      'Password reset link sent to your email!');
                } catch (e) {
                  _showErrorMessage(
                      'Failed to send reset email. Please try again.');
                }
              } else {
                _showErrorMessage('Please enter a valid email address.');
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Center(
                      child: Text(
                        'LA',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Lectry AI',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Transform your notes into structured insights',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: _onTabChanged,
                indicator: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Sign Up'),
                  Tab(text: 'Log In'),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Form Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Sign Up Form
                  AuthFormWidget(
                    isSignUp: true,
                    isLoading: _isLoading,
                    onSubmit: (formData) =>
                        _handleAuthentication(true, formData),
                    onForgotPassword: null,
                  ),
                  // Log In Form
                  AuthFormWidget(
                    isSignUp: false,
                    isLoading: _isLoading,
                    onSubmit: (formData) =>
                        _handleAuthentication(false, formData),
                    onForgotPassword: _handleForgotPassword,
                  ),
                ],
              ),
            ),

            // Social Login Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'OR',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Social Login Buttons
                  SocialLoginWidget(
                    isLoading: _isLoading,
                    onSocialLogin: _handleSocialLogin,
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Terms and Privacy
            const TermsPrivacyWidget(),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
