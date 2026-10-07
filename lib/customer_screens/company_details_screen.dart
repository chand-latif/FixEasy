import 'package:flutter/material.dart';
import '../theme.dart';
import 'service_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fix_easy/widgets/image_viewer.dart';
import 'package:shimmer/shimmer.dart';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyDetailsScreen({Key? key, required this.company})
      : super(key: key);

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  bool isLoading = true;
  List<ServiceModel> services = [];

  @override
  void initState() {
    super.initState();
    fetchCompanyServices();
  }

  Future<void> fetchCompanyServices() async {
    final companyId =
        widget.company['id'] ?? widget.company['companyId'] as int?;
    if (companyId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final result =
          await ServiceRepository().getPublishedServices(companyId as int);
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
            SnackBar(content: Text('Error loading services: $e')));
      }
    }
  }

  String _logoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return 'https://fixease.pk$raw';
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone call')));
      }
    }
  }

  Future<void> _launchWhatsApp(String number) async {
    try {
      await launchUrl(Uri.parse('whatsapp://send?phone=$number'));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    }
  }

  Widget _buildServiceShimmer() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 120, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 16, color: Colors.white),
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
    final logoUrl = _logoUrl(widget.company['companyLogo'] as String?);
    final phone = widget.company['phoneNumber'] as String? ??
        widget.company['companyPhone'] as String?;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: logoUrl.isNotEmpty
                        ? () => ImageViewer.showFullScreenImage(
                            context, logoUrl)
                        : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.business, size: 60,
                                        color: Colors.grey)),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.business,
                                    size: 60, color: Colors.grey)),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    widget.company['companyName'] ?? 'Company',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Company Information',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  if (widget.company['companyAddress'] != null)
                                    ListTile(
                                      leading: const Icon(Icons.location_on),
                                      title: Text(
                                          widget.company['companyAddress']),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  if (widget.company['description'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.company['description'],
                                      style:
                                          TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: phone != null
                                              ? () => _launchPhoneCall(phone)
                                              : null,
                                          icon: const Icon(Icons.phone),
                                          label: const Text('Call'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: phone != null
                                              ? () => _launchWhatsApp(phone)
                                              : null,
                                          icon: const FaIcon(
                                              FontAwesomeIcons.whatsapp,
                                              color: Colors.green,
                                              size: 22),
                                          label: const Text('WhatsApp'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xFF90DD93),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Available Services',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    if (isLoading)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (_, __) => _buildServiceShimmer(),
                      )
                    else if (services.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.engineering_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No services available at the moment',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final s = services[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailsScreen(
                                    service: {
                                      'id': s.serviceId,
                                      'serviceId': s.serviceId,
                                      'name': s.serviceName,
                                      'providerName': s.serviceName,
                                      'description': s.serviceDescription,
                                      'serviceDescription':
                                          s.serviceDescription,
                                      'image': s.serviceImage,
                                      'price': s.price,
                                      'categoryName': s.categoryName,
                                      'companyName': s.companyName,
                                      'serviceReview': const [],
                                      'serviceRating': {
                                        'averageRating': 0.0,
                                        'totalRatings': 0
                                      },
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (s.serviceImage != null &&
                                      s.serviceImage!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                      child: Image.network(
                                        s.serviceImage!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image)),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (s.categoryName != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(s.categoryName!,
                                                style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12)),
                                          ),
                                        const SizedBox(height: 6),
                                        Text(s.serviceName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        if (s.serviceDescription != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            s.serviceDescription!,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          'PKR ${s.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
