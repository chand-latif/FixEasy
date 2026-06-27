import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

class SignUp extends StatefulWidget {
  final String accountType;
  const SignUp({super.key, required this.accountType});

  @override
  State<SignUp> createState() => _SignUpState();
}

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();

class _SignUpState extends State<SignUp> {
  bool isObscurePassword = true;
  bool isObscureConfirmPassword = true;

  String? emailError;
  String? phoneError;
  String? passwordError;
  String? nameError;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  void validateEmail(String email) {
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    setState(() {
      if (email.isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Enter a valid email';
      } else {
        emailError = null;
      }
    });
  }

  void validatePhone(String phone) {
    setState(() {
      if (phone.isEmpty) {
        phoneError = 'Phone number is required';
      } else if (phone.length != 11) {
        phoneError = 'Phone number must be 11 digits';
      } else {
        phoneError = null;
      }
    });
  }

  void validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        passwordError = 'Password is required';
      } else if (password.length < 6) {
        passwordError = 'Password must be at least 6 characters';
      } else {
        passwordError = null;
      }
    });
  }

  void validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        nameError = 'Name is required';
      } else {
        nameError = null;
      }
    });
  }

  bool isFormValid() {
    validateName(nameController.text);
    validateEmail(emailController.text);
    validatePhone(phoneController.text);
    validatePassword(passwordController.text);

    return nameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        passwordController.text == confirmPasswordController.text;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Profile Picture',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera),
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _showImagePickerOptions,
          child: Text('Choose Profile Picture'),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (!isFormValid()) return;

    final nameParts = nameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneController.text.trim(),
      userType: widget.accountType,
    );

    if (!mounted) return;

    if (success) {
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful!'),
          content: Text(
            'A confirmation email has been sent to ${emailController.text}. '
            'Please check your inbox and verify your email before signing in.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('Sign Up'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Make your future bright with us!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create New Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildImagePicker(),
                SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          'Full Name',
                          nameController,
                          Icons.person,
                          validateName,
                          nameError,
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          'Email Address',
                          emailController,
                          Icons.email,
                          validateEmail,
                          emailError,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          'Phone Number',
                          phoneController,
                          Icons.phone,
                          validatePhone,
                          phoneError,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildPasswordField(
                          'Password',
                          passwordController,
                          isObscurePassword,
                          (value) {
                            setState(() => isObscurePassword = !isObscurePassword);
                          },
                          validatePassword,
                          passwordError,
                        ),
                        SizedBox(height: 16),
                        _buildPasswordField(
                          'Confirm Password',
                          confirmPasswordController,
                          isObscureConfirmPassword,
                          (value) {
                            setState(() =>
                                isObscureConfirmPassword =
                                    !isObscureConfirmPassword);
                          },
                          null,
                          null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Consumer<AuthViewModel>(
                  builder: (context, authVM, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: authVM.isLoading ? null : _signUp,
                    child: authVM.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating Account...'),
                            ],
                          )
                        : Text('Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/home'),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
    Function(String)? onChanged,
    String? errorText, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isObscure,
    Function(bool) onToggle,
    Function(String)? onChanged,
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: label == 'Password'
                ? 'Enter your password'
                : 'Re-enter your password',
            prefixIcon: Icon(Icons.lock, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () => onToggle(!isObscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
