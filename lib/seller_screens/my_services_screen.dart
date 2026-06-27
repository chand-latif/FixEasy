import 'package:flutter/material.dart';
import '../theme.dart';
import 'update_service_screen.dart';
import 'nav_bar_seller.dart';
import 'package:shimmer/shimmer.dart';
import 'seller_service_details_screen.dart';
import 'create_service.dart';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';

class MyServicesScreen extends StatefulWidget {
  final int companyId;
  const MyServicesScreen({super.key, required this.companyId});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final _serviceRepo = ServiceRepository();
  bool isLoading = true;
  List<ServiceModel> services = [];

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final result =
          await _serviceRepo.getAllCompanyServices(widget.companyId);
      if (mounted) {
        setState(() {
          services = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  Future<void> deleteService(int serviceId) async {
    try {
      await _serviceRepo.deleteService(serviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        fetchServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> confirmDelete(int serviceId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteService(serviceId);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceShimmer() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 150, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 24, color: Colors.white),
                      Row(
                        children: [
                          Container(width: 32, height: 32, color: Colors.white),
                          const SizedBox(width: 8),
                          Container(width: 32, height: 32, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, __) => _buildServiceShimmer(),
            )
          : services.isEmpty
              ? const Center(child: Text('No services found'))
              : RefreshIndicator(
                  onRefresh: fetchServices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SellerServiceDetailsScreen(
                                service: {
                                  'id': service.serviceId,
                                  'name': service.serviceName,
                                  'description': service.serviceDescription,
                                  'price': service.price,
                                  'image': service.serviceImage,
                                  'categoryName': service.categoryName,
                                  'categoryId': service.categoryId,
                                  'is_published': service.isPublished,
                                },
                                companyId: widget.companyId,
                                onServiceUpdated: fetchServices,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service Image
                              if (service.serviceImage != null &&
                                  service.serviceImage!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                  child: Image.network(
                                    service.serviceImage!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image,
                                          size: 50),
                                    ),
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (service.categoryName != null)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              service.categoryName!,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else
                                          const SizedBox(),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        UpdateServiceScreen(
                                                      serviceId: service.serviceId,
                                                      companyId:
                                                          widget.companyId,
                                                      initialData: {
                                                        'name': service.serviceName,
                                                        'description':
                                                            service.serviceDescription,
                                                        'price': service.price,
                                                        'categoryId':
                                                            service.categoryId,
                                                        'categoryName':
                                                            service.categoryName,
                                                        'image': service.serviceImage,
                                                      },
                                                    ),
                                                  ),
                                                ).then((value) {
                                                  if (value == true)
                                                    fetchServices();
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  confirmDelete(service.serviceId),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      service.serviceName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    if (service.serviceDescription != null)
                                      Text(
                                        service.serviceDescription!,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'PKR ${service.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (service.rating != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 20),
                                          Text(
                                            ' ${service.rating!.averageRating.toStringAsFixed(1)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            ' (${service.rating!.totalRatings})',
                                            style: TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: NavBarSeller(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateServiceScreen(companyID: widget.companyId),
            ),
          ).then((_) => fetchServices());
        },
        label: const Text('Add Service'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
