import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../theme.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import 'nav_bar_seller.dart';
import 'create_service.dart';
import 'my_services_screen.dart';

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key});

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome> {
  SupabaseClient get _supabase => Supabase.instance.client;

  int pendingBookings = 0;
  int inProgressBookings = 0;
  int finishedBookings = 0;
  double averageRating = 0.0;
  int totalRatings = 0;
  int? companyId;
  bool isLoading = true;
  List<Map<String, dynamic>> recentBookings = [];
  String? companyName;
  String? companyLogo;
  bool isLoadingCompanyInfo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authVM = context.read<AuthViewModel>();
    companyId = authVM.companyId;
    if (companyId == null) return;

    await Future.wait([
      _fetchCompanyInfo(),
      _fetchStats(),
      _fetchRecentBookings(),
    ]);
  }

  Future<void> _fetchCompanyInfo() async {
    try {
      final data = await _supabase
          .from('company_profiles')
          .select('company_name, logo')
          .eq('id', companyId!)
          .single();
      if (mounted) {
        setState(() {
          companyName = data['company_name'];
          companyLogo = data['logo'];
          isLoadingCompanyInfo = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingCompanyInfo = false);
    }
  }

  Future<void> _fetchStats() async {
    try {
      final data = await _supabase
          .from('bookings')
          .select('status')
          .eq('company_id', companyId!);
      if (mounted) {
        setState(() {
          pendingBookings =
              data.where((b) => b['status'] == 'Pending').length;
          inProgressBookings =
              data.where((b) => b['status'] == 'InProgress').length;
          finishedBookings =
              data.where((b) => b['status'] == 'Completed').length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchRecentBookings() async {
    try {
      final data = await _supabase
          .from('bookings')
          .select('*, services(name), profiles!customer_id(first_name, last_name)')
          .eq('company_id', companyId!)
          .order('created_at', ascending: false)
          .limit(3);
      if (mounted) {
        setState(() {
          recentBookings = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      // Silently fail — bookings section will just be empty
    }
  }

  String _customerName(Map<String, dynamic> booking) {
    final p = booking['profiles'];
    if (p == null) return 'Customer';
    return '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
  }

  String _serviceName(Map<String, dynamic> booking) {
    final s = booking['services'];
    return s?['name'] ?? 'Service';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Accepted': return Colors.blue;
      case 'InProgress': return Colors.indigo;
      case 'Completed': return Colors.green;
      case 'Rejected':
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Pending': return Icons.schedule;
      case 'Accepted': return Icons.thumb_up_outlined;
      case 'InProgress': return Icons.engineering;
      case 'Completed': return Icons.check_circle_outline;
      case 'Rejected':
      case 'Cancelled': return Icons.cancel_outlined;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Image.asset('assets/FixEasy.png', height: 100, fit: BoxFit.contain),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/sellerProfile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildServiceManagement(),
              const SizedBox(height: 24),
              const Text(
                'Booking Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              isLoading ? _buildOverviewShimmer() : _buildBookingOverview(),
              const SizedBox(height: 24),
              const Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRecentBookings(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarSeller(),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyan, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoadingCompanyInfo ? 'Loading...' : (companyName ?? 'My Company'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (isLoadingCompanyInfo)
            Shimmer.fromColors(
              baseColor: Colors.white24,
              highlightColor: Colors.white38,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: companyLogo != null && companyLogo!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(companyLogo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: companyLogo == null || companyLogo!.isEmpty
                  ? const Icon(Icons.business, color: Colors.grey, size: 30)
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildServiceManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Create New\nService',
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateServiceScreen(companyID: companyId ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 20),
            _buildActionButton(
              icon: Icons.build_circle_outlined,
              label: 'My\nServices',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyServicesScreen(companyId: companyId ?? 0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBookingOverview() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOverviewCard('Pending', pendingBookings.toString(),
            Icons.schedule, Colors.orange,
            () => Navigator.pushNamed(context, '/sellerBookingRequests')),
        _buildOverviewCard('In Progress', inProgressBookings.toString(),
            Icons.engineering, Colors.blue,
            () => Navigator.pushNamed(context, '/sellerBookingRequests')),
        _buildOverviewCard('Completed', finishedBookings.toString(),
            Icons.check_circle_outline, Colors.green,
            () => Navigator.pushNamed(context, '/sellerBookingRequests')),
        _buildRatingCard(),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String count, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(count,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Text(averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$totalRatings Reviews',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildOverviewShimmer() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 40, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 60, height: 16, color: Colors.white),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentBookings() {
    if (recentBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('No bookings yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentBookings.map((booking) {
        final status = booking['status'] as String?;
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _customerName(booking),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status),
                              size: 14, color: _statusColor(status)),
                          const SizedBox(width: 4),
                          Text(
                            status ?? 'Unknown',
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _serviceName(booking),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (booking['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    booking['description'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking['booking_date']),
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (booking['total_price'] != null) ...[
                      const Spacer(),
                      Text(
                        'PKR ${booking['total_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
