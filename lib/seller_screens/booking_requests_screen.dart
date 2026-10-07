import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../theme.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import 'nav_bar_seller.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  SupabaseClient get _supabase => Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> allBookings = [];
  List<Map<String, dynamic>> bookings = [];
  String? selectedStatus;
  int? companyId;
  bool isUpdatingStatus = false;
  int? updatingBookingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyId = Provider.of<AuthViewModel>(context, listen: false).companyId;
      fetchBookings();
    });
  }

  Future<void> fetchBookings([String? status]) async {
    if (companyId == null) return;
    setState(() => isLoading = true);
    try {
      final data = await _supabase
          .from('bookings')
          .select(
              '*, services(name, categories(name)), profiles!customer_id(first_name, last_name)')
          .eq('company_id', companyId!)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          allBookings = List<Map<String, dynamic>>.from(data);
          _applyFilter(status);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Unable to load bookings. Please try again.')),
        );
      }
    }
  }

  void _applyFilter(String? status) {
    setState(() {
      selectedStatus = status;
      bookings = status == null
          ? allBookings
          : allBookings.where((b) => b['status'] == status).toList();
    });
  }

  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    setState(() {
      isUpdatingStatus = true;
      updatingBookingId = bookingId;
    });
    try {
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking $newStatus successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await fetchBookings(selectedStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingStatus = false;
          updatingBookingId = null;
        });
      }
    }
  }

  String _customerName(Map<String, dynamic> b) {
    final p = b['profiles'];
    if (p == null) return 'Customer';
    return '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
  }

  String _serviceName(Map<String, dynamic> b) =>
      b['services']?['name'] ?? 'Service';

  String _categoryName(Map<String, dynamic> b) =>
      b['services']?['categories']?['name'] ?? 'N/A';

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'Pending': return Colors.orange;
      case 'Accepted': return Colors.blue;
      case 'InProgress': return Colors.indigo;
      case 'Completed': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'Pending': return Icons.schedule;
      case 'Accepted': return Icons.thumb_up_outlined;
      case 'InProgress': return Icons.engineering;
      case 'Completed': return Icons.check_circle_outline;
      case 'Rejected':
      case 'Cancelled': return Icons.cancel_outlined;
      default: return Icons.circle_outlined;
    }
  }

  Widget _buildActions(Map<String, dynamic> booking) {
    final id = booking['id'] as int;
    final status = booking['status'] as String?;
    final isUpdating = isUpdatingStatus && updatingBookingId == id;

    if (status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isUpdating
                  ? null
                  : () => updateBookingStatus(id, 'Rejected'),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isUpdating
                  ? null
                  : () => updateBookingStatus(id, 'Accepted'),
              child: isUpdating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Accept'),
            ),
          ),
        ],
      );
    }

    if (status == 'Accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed:
              isUpdating ? null : () => updateBookingStatus(id, 'InProgress'),
          child: isUpdating
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Start Work'),
        ),
      );
    }

    if (status == 'InProgress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed:
              isUpdating ? null : () => updateBookingStatus(id, 'Completed'),
          child: isUpdating
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Mark as Completed'),
        ),
      );
    }

    // Terminal states — just show a badge
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_statusIcon(status), color: _statusColor(status), size: 16),
          const SizedBox(width: 6),
          Text(
            status ?? 'Unknown',
            style: TextStyle(
                color: _statusColor(status), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 150, height: 20, color: Colors.white),
                  Container(width: 80, height: 20, color: Colors.white),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 14, width: 200, color: Colors.white),
              const SizedBox(height: 16),
              Container(height: 40, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('All', null, Colors.grey),
      ('Pending', 'Pending', Colors.orange),
      ('Accepted', 'Accepted', Colors.blue),
      ('In Progress', 'InProgress', Colors.indigo),
      ('Completed', 'Completed', Colors.green),
      ('Rejected', 'Rejected', Colors.red),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedStatus == f.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.$1),
              selected: isSelected,
              onSelected: (_) {
                _applyFilter(f.$2);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: f.$3.withValues(alpha: 0.2),
              checkmarkColor: f.$3,
              labelStyle: TextStyle(
                color: isSelected ? f.$3 : Colors.grey[700],
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (_, __) => _buildShimmer(),
                  )
                : bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              selectedStatus != null
                                  ? 'No $selectedStatus bookings'
                                  : 'No bookings yet',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => fetchBookings(selectedStatus),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            final status = booking['status'] as String?;
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _customerName(booking),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(_statusIcon(status),
                                                  size: 13,
                                                  color: _statusColor(status)),
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
                                    const SizedBox(height: 10),
                                    _infoRow(Icons.build_outlined,
                                        _serviceName(booking)),
                                    const SizedBox(height: 6),
                                    _infoRow(Icons.category_outlined,
                                        _categoryName(booking)),
                                    if (booking['description'] != null) ...[
                                      const SizedBox(height: 6),
                                      _infoRow(
                                          Icons.notes, booking['description'],
                                          maxLines: 2),
                                    ],
                                    if (booking['address'] != null) ...[
                                      const SizedBox(height: 6),
                                      _infoRow(Icons.location_on_outlined,
                                          booking['address']),
                                    ],
                                    const SizedBox(height: 6),
                                    _infoRow(Icons.calendar_today_outlined,
                                        _formatDate(booking['booking_date'])),
                                    if (booking['total_price'] != null) ...[
                                      const SizedBox(height: 6),
                                      _infoRow(Icons.payments_outlined,
                                          'PKR ${booking['total_price']}',
                                          color: AppColors.primary),
                                    ],
                                    const SizedBox(height: 12),
                                    _buildActions(booking),
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
      bottomNavigationBar: const NavBarSeller(currentIndex: 1),
    );
  }

  Widget _infoRow(IconData icon, String text,
      {int maxLines = 1, Color? color}) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: color ?? Colors.grey[600], fontSize: 13),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
