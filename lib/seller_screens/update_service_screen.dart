import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fix_easy/theme.dart';
import '../data/repositories/service_repository.dart';

class UpdateServiceScreen extends StatefulWidget {
  final int serviceId;
  final int companyId;
  final Map<String, dynamic> initialData;

  const UpdateServiceScreen({
    super.key,
    required this.serviceId,
    required this.companyId,
    required this.initialData,
  });

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final _serviceRepo = ServiceRepository();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final Map<String, int> serviceCategories = {
    'Plumbing': 1,
    'Electrical': 2,
    'Cleaning': 3,
    'Painting': 4,
    'Carpentry': 5,
    'AC & Appliances': 6,
    'Pest Control': 7,
    'Shifting & Moving': 8,
  };

  String? selectedCategory;
  int? selectedCategoryId;
  File? serviceImage;
  String? existingImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialData['name']?.toString() ?? '';
    descriptionController.text =
        widget.initialData['description']?.toString() ?? '';
    priceController.text =
        widget.initialData['price']?.toString() ?? '';
    existingImageUrl = widget.initialData['image']?.toString();

    // Resolve category
    final catName = widget.initialData['categoryName']?.toString();
    final catId = widget.initialData['categoryId'] as int?;

    if (catName != null && serviceCategories.containsKey(catName)) {
      selectedCategory = catName;
      selectedCategoryId = serviceCategories[catName];
    } else if (catId != null) {
      final entry = serviceCategories.entries
          .firstWhere((e) => e.value == catId, orElse: () => serviceCategories.entries.first);
      selectedCategory = entry.key;
      selectedCategoryId = entry.value;
    } else {
      selectedCategory = serviceCategories.keys.first;
      selectedCategoryId = serviceCategories.values.first;
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => serviceImage = File(picked.path));
  }

  Future<void> updateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await _serviceRepo.updateService(
        serviceId: widget.serviceId,
        serviceName: nameController.text.trim(),
        serviceDescription: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.trim()),
        categoryId: selectedCategoryId,
        isPublished: true,
      );

      if (serviceImage != null) {
        await _serviceRepo.uploadServiceImage(
          serviceId: widget.serviceId,
          imagePath: serviceImage!.path,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully'),
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text('Tap to change image',
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Update Service'),
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
                // Image card
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
                        const Text('Service Image',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: serviceImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(serviceImage!,
                                        fit: BoxFit.cover),
                                  )
                                : (existingImageUrl != null &&
                                        existingImageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          existingImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildImagePlaceholder(),
                                        ),
                                      )
                                    : _buildImagePlaceholder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Details card
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
                        const Text('Service Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: nameController,
                          decoration:
                              _inputDeco('Service Name', Icons.handyman),
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: _inputDeco('Category', Icons.category),
                          items: serviceCategories.keys
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              selectedCategoryId =
                                  serviceCategories[value];
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Please select a category' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: priceController,
                          decoration:
                              _inputDeco('Price (PKR)', Icons.attach_money),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(v!) == null)
                              return 'Enter a valid price';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descriptionController,
                          decoration:
                              _inputDeco('Description', Icons.description),
                          maxLines: 4,
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : updateService,
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
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Update Service',
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
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
