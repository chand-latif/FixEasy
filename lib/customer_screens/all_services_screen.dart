import 'package:flutter/material.dart';
import '../theme.dart';
import 'service_details_screen.dart';
import 'nav_bar_customer.dart';
import 'package:fix_easy/widgets/image_viewer.dart';
import 'package:shimmer/shimmer.dart';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final _serviceRepo = ServiceRepository();
  bool isLoading = true;
  List<ServiceModel> services = [];
  List<ServiceModel> filteredServices = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllServices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllServices() async {
    try {
      final result = await _serviceRepo.getAllPublishedServices();
      if (mounted) {
        setState(() {
          services = result;
          filteredServices = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load services. Please check your internet connection and try again.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void searchServices(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services.where((s) {
          return s.serviceName.toLowerCase().contains(q) ||
              (s.serviceDescription?.toLowerCase().contains(q) ?? false) ||
              (s.categoryName?.toLowerCase().contains(q) ?? false) ||
              (s.companyName?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  Widget _buildServiceShimmer() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 120, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 120, height: 20, color: Colors.white),
                      Container(width: 80, height: 20, color: Colors.white),
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

  Map<String, dynamic> _toServiceMap(ServiceModel s) {
    return {
      'id': s.serviceId,
      'serviceId': s.serviceId,
      'serviceName': s.serviceName,
      'providerName': s.serviceName,
      'serviceDescription': s.serviceDescription,
      'categoryName': s.categoryName,
      'categoryId': s.categoryId,
      'serviceImage': s.serviceImage,
      'price': s.price,
      'companyName': s.companyName,
      'companyId': s.companyId,
      'is_published': s.isPublished,
      'serviceRating': {
        'averageRating': s.rating?.averageRating ?? 0.0,
        'totalRatings': s.rating?.totalRatings ?? 0,
      },
      'contactNumber': null,
      'address': null,
      'serviceTags': null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('All Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search services by name or category...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: searchController.text.isNotEmpty
                          ? AppColors.primary
                          : Colors.grey[400]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: Colors.grey[400]),
                          onPressed: () {
                            searchController.clear();
                            searchServices('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: searchServices,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (_, __) => _buildServiceShimmer(),
                  )
                : filteredServices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.handyman_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isNotEmpty
                                  ? 'No services match your search'
                                  : 'No services available yet',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchAllServices,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailsScreen(
                                      service: _toServiceMap(service),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (service.serviceImage != null &&
                                        service.serviceImage!.isNotEmpty)
                                      GestureDetector(
                                        onTap: () =>
                                            ImageViewer.showFullScreenImage(
                                          context,
                                          service.serviceImage!,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            service.serviceImage!,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image,
                                                  size: 50),
                                            ),
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
                                              Expanded(
                                                child: Text(
                                                  service.serviceName,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (service.categoryName != null)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (service.companyName != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'by ${service.companyName}',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13),
                                            ),
                                          ],
                                          if (service.serviceDescription !=
                                              null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              service.serviceDescription!,
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'PKR ${service.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              if (service.rating != null)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star,
                                                        color: Colors.amber,
                                                        size: 16),
                                                    Text(
                                                      ' ${service.rating!.averageRating.toStringAsFixed(1)}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13),
                                                    ),
                                                    Text(
                                                      ' (${service.rating!.totalRatings})',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
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
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2),
    );
  }
}
