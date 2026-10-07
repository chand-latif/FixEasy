import 'package:flutter/material.dart';
import 'package:fix_easy/theme.dart';
import 'update_service_screen.dart';
import '../data/repositories/service_repository.dart';

class SellerServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  final int companyId;
  final VoidCallback? onServiceUpdated;

  const SellerServiceDetailsScreen({
    Key? key,
    required this.service,
    required this.companyId,
    this.onServiceUpdated,
  }) : super(key: key);

  Future<void> _deleteService(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ServiceRepository().deleteService(service['id'] as int);
      if (onServiceUpdated != null) onServiceUpdated!();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting service: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = service['image'] as String?;
    final isPublished = service['is_published'] as bool? ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateServiceScreen(
                    serviceId: service['id'] as int,
                    companyId: companyId,
                    initialData: {
                      'name': service['name'],
                      'description': service['description'],
                      'price': service['price'],
                      'categoryId': service['categoryId'],
                      'categoryName': service['categoryName'],
                      'image': service['image'],
                    },
                  ),
                ),
              ).then((value) {
                if (value == true && onServiceUpdated != null) {
                  onServiceUpdated!();
                  Navigator.pop(context);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[200]),
            onPressed: () => _deleteService(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service['name'] ?? 'Service',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPublished
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPublished ? 'Published' : 'Draft',
                          style: TextStyle(
                            color:
                                isPublished ? Colors.green : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (service['categoryName'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service['categoryName'],
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'PKR ${service['price']?.toString() ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (service['description'] != null) ...[
                    const SizedBox(height: 24),
                    Text('Description',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        service['description'],
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
