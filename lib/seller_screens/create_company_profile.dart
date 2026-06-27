import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fix_easy/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/repositories/company_repository.dart';

class CreateCompanyProfileScreen extends StatefulWidget {
  const CreateCompanyProfileScreen({super.key});

  @override
  _CreateCompanyProfileScreenState createState() =>
      _CreateCompanyProfileScreenState();
}

class _CreateCompanyProfileScreenState
    extends State<CreateCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final _companyRepo = CompanyRepository();

  final companyNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final whatsappNumberController = TextEditingController();
  final companyAddressController = TextEditingController();

  File? companyLogo;
  bool isLoading = false;
  String? phoneError;
  String? whatsappNumberError;

  Map<String, TimeOfDay?> workingHoursStart = {};
  Map<String, TimeOfDay?> workingHoursEnd = {};
  Map<String, bool> dayOff = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => companyLogo = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => companyLogo = File(pickedFile.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickTime(BuildContext context, String day, bool isStart) async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          workingHoursStart[day] = picked;
        } else {
          workingHoursEnd[day] = picked;
        }
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final company = await _companyRepo.createCompanyProfile(
        companyName: companyNameController.text.trim(),
        companyAddress: companyAddressController.text.trim(),
        companyPhone: phoneNumberController.text.trim(),
      );

      if (companyLogo != null) {
        await _companyRepo.uploadCompanyLogo(
          companyId: company.companyId,
          logoPath: companyLogo!.path,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company Profile Created Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/sellerHome', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

  void validateWhatsapp(String phone) {
    setState(() {
      if (phone.isEmpty) {
        whatsappNumberError = 'WhatsApp number is required';
      } else if (phone.length != 11) {
        whatsappNumberError = 'WhatsApp number must be 11 digits';
      } else {
        whatsappNumberError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Company Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Logo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: companyLogo != null
                                      ? FileImage(companyLogo!)
                                      : null,
                                  child: companyLogo == null
                                      ? Icon(Icons.camera_alt,
                                          size: 40, color: Colors.grey[600])
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                companyLogo == null
                                    ? 'Tap to add logo'
                                    : 'Tap to change logo',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              if (companyLogo != null)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => companyLogo = null),
                                  child: const Text('Remove Logo',
                                      style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: companyNameController,
                          decoration:
                              _inputDeco('Company Name', Icons.business),
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Please enter company name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneNumberController,
                          decoration: _inputDeco('Phone Number', Icons.phone),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          onChanged: validatePhone,
                          forceErrorText: phoneError,
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Required' : phoneError,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: whatsappNumberController,
                          decoration: _inputDeco(
                              'WhatsApp Number', FontAwesomeIcons.whatsapp),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          onChanged: validateWhatsapp,
                          forceErrorText: whatsappNumberError,
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Required'
                              : whatsappNumberError,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: companyAddressController,
                          decoration:
                              _inputDeco('Company Address', Icons.location_on),
                          maxLines: 2,
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Please enter company address'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Working hours card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Working Hours (Optional)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your working hours or mark days as off',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ...dayOff.keys
                            .map((day) => _buildTimePickerRow(day))
                            .toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Create Profile',
                          style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(String day) {
    final isOff = dayOff[day] ?? false;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isOff ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isOff ? null : () => pickTime(context, day, true),
                        style: _timeButtonStyle(isOff),
                        child: Text(
                          workingHoursStart[day]?.format(context) ?? '--:--',
                          style: TextStyle(
                              color: isOff ? Colors.grey : AppColors.primary,
                              fontSize: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('to', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isOff ? null : () => pickTime(context, day, false),
                        style: _timeButtonStyle(isOff),
                        child: Text(
                          workingHoursEnd[day]?.format(context) ?? '--:--',
                          style: TextStyle(
                              color: isOff ? Colors.grey : AppColors.primary,
                              fontSize: 12),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isOff,
                        onChanged: (value) {
                          setState(() {
                            dayOff[day] = value;
                            if (value) {
                              workingHoursStart[day] = null;
                              workingHoursEnd[day] = null;
                            }
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (day != dayOff.keys.last) const Divider(height: 1),
      ],
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  ButtonStyle _timeButtonStyle(bool isOff) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      side: BorderSide(
          color: isOff ? Colors.grey.shade300 : AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    phoneNumberController.dispose();
    whatsappNumberController.dispose();
    companyAddressController.dispose();
    super.dispose();
  }
}
