import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';

class AuthFormWidget extends StatefulWidget {
  final bool isSignUp;
  final bool isLoading;
  final Function(Map<String, String>) onSubmit;
  final VoidCallback? onForgotPassword;

  const AuthFormWidget({
    Key? key,
    required this.isSignUp,
    required this.isLoading,
    required this.onSubmit,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    final score = _authService.getPasswordStrength(password);
    final label = _authService.getPasswordStrengthLabel(score);

    setState(() {
      _passwordStrength = label;
      switch (score) {
        case 0:
        case 1:
          _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
          break;
        case 2:
        case 3:
          _passwordStrengthColor = AppTheme.warningLight;
          break;
        case 4:
        case 5:
          _passwordStrengthColor = AppTheme.lightTheme.colorScheme.tertiary;
          break;
      }
    });
  }

  bool _isFormValid() {
    if (widget.isSignUp) {
      return _nameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _authService.isValidPassword(_passwordController.text) &&
          _authService.isValidEmail(_emailController.text.trim());
    } else {
      return _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _authService.isValidEmail(_emailController.text.trim());
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final formData = <String, String>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      if (widget.isSignUp) {
        formData['name'] = _nameController.text.trim();
        formData['confirmPassword'] = _confirmPasswordController.text;
      }

      widget.onSubmit(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field (Sign Up only)
            if (widget.isSignUp) ...[
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
            ],

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!_authService.isValidEmail(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction:
                  widget.isSignUp ? TextInputAction.next : TextInputAction.done,
              onChanged: widget.isSignUp ? _checkPasswordStrength : null,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName:
                        _isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (widget.isSignUp && !_authService.isValidPassword(value)) {
                  return 'Password must be at least 8 characters with uppercase, lowercase, and numbers';
                }
                return null;
              },
            ),

            // Password strength indicator (Sign Up only)
            if (widget.isSignUp && _passwordStrength.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  Text(
                    'Password strength: ',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Text(
                    _passwordStrength,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 2.h),

            // Confirm Password field (Sign Up only)
            if (widget.isSignUp) ...[
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: _isConfirmPasswordVisible
                          ? 'visibility_off'
                          : 'visibility',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
            ],

            // Forgot Password link (Log In only)
            if (!widget.isSignUp && widget.onForgotPassword != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
            ],

            // Submit Button
            SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: (_isFormValid() && !widget.isLoading)
                    ? _handleSubmit
                    : null,
                child: widget.isLoading
                    ? SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.isSignUp ? 'Create Account' : 'Sign In',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
