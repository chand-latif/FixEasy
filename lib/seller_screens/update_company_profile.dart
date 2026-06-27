import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fix_easy/theme.dart';
import '../data/repositories/company_repository.dart';

class UpdateCompanyProfileScreen extends StatefulWidget {
  final int companyId;
  const UpdateCompanyProfileScreen({super.key, required this.companyId});

  @override
  _UpdateCompanyProfileScreenState createState() =>
      _UpdateCompanyProfileScreenState();
}

class _UpdateCompanyProfileScreenState
    extends State<UpdateCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final _companyRepo = CompanyRepository();

  final companyNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  String? existingLogoUrl;
  File? newLogo;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    try {
      final company = await _companyRepo.getCompanyProfile(widget.companyId);
      setState(() {
        companyNameController.text = company.companyName;
        phoneController.text = company.companyPhone ?? '';
        emailController.text = company.companyEmail ?? '';
        addressController.text = company.companyAddress ?? '';
        descriptionController.text = company.companyDescription ?? '';
        existingLogoUrl = company.companyLogo;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> pickLogo() async {
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
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                if (picked != null) setState(() => newLogo = File(picked.path));
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => newLogo = File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    try {
      await _companyRepo.updateCompanyProfile(
        companyId: widget.companyId,
        companyName: companyNameController.text.trim(),
        companyPhone: phoneController.text.trim(),
        companyEmail: emailController.text.trim(),
        companyAddress: addressController.text.trim(),
        companyDescription: descriptionController.text.trim(),
      );

      if (newLogo != null) {
        await _companyRepo.uploadCompanyLogo(
          companyId: widget.companyId,
          logoPath: newLogo!.path,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update Company Profile'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Update Company Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              onTap: pickLogo,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: newLogo != null
                                    ? FileImage(newLogo!) as ImageProvider
                                    : (existingLogoUrl != null &&
                                            existingLogoUrl!.isNotEmpty
                                        ? NetworkImage(existingLogoUrl!)
                                        : null),
                                child: (newLogo == null &&
                                        (existingLogoUrl == null ||
                                            existingLogoUrl!.isEmpty))
                                    ? Icon(Icons.camera_alt,
                                        size: 40, color: Colors.grey[600])
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Tap to change logo',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            if (newLogo != null)
                              TextButton(
                                onPressed: () => setState(() => newLogo = null),
                                child: const Text('Remove',
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

              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        decoration: _inputDeco('Company Name', Icons.business),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: _inputDeco('Phone Number', Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: _inputDeco('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: _inputDeco('Address', Icons.location_on),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: _inputDeco(
                            'Description (optional)', Icons.info_outline),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  @override
  void dispose() {
    companyNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
