import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  static const _bookingSelect = '''
    *,
    services(id, name, image),
    profiles!customer_id(first_name, last_name, phone_number, profile_image),
    company_profiles(company_name, logo)
  ''';

  Future<List<BookingModel>> getAllBookings() async {
    final response = await _supabase
        .from('bookings')
        .select(_bookingSelect)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  Future<BookingModel> getBookingDetails(int bookingId) async {
    final response = await _supabase
        .from('bookings')
        .select(_bookingSelect)
        .eq('id', bookingId)
        .single();

    return BookingModel.fromJson(response);
  }

  Future<BookingModel> createBooking({
    required int serviceId,
    required DateTime bookingDate,
    required String bookingTime,
    required String address,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    final customerId = _supabase.auth.currentUser!.id;

    // Get company_id from the service
    final serviceData = await _supabase
        .from('services')
        .select('company_id, price')
        .eq('id', serviceId)
        .single();

    final response = await _supabase
        .from('bookings')
        .insert({
          'service_id': serviceId,
          'customer_id': customerId,
          'company_id': serviceData['company_id'],
          'booking_date': bookingDate.toIso8601String().split('T')[0],
          'booking_time': bookingTime,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'description': description,
          'total_price': serviceData['price'],
        })
        .select(_bookingSelect)
        .single();

    return BookingModel.fromJson(response);
  }

  Future<void> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    await _supabase
        .from('bookings')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', bookingId);
  }

  Future<BookingStats> getBookingStats() async {
    final response = await _supabase
        .from('bookings')
        .select('status');

    final statuses = (response as List).map((b) => b['status'] as String).toList();

    return BookingStats(
      pending: statuses.where((s) => s == 'Pending').length,
      accepted: statuses.where((s) => s == 'Accepted').length,
      inProgress: statuses.where((s) => s == 'InProgress').length,
      completed: statuses.where((s) => s == 'Completed').length,
    );
  }

  Future<BookingModel> updateBooking({
    required int bookingId,
    DateTime? bookingDate,
    String? bookingTime,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    final response = await _supabase
        .from('bookings')
        .update({
          if (bookingDate != null)
            'booking_date': bookingDate.toIso8601String().split('T')[0],
          if (bookingTime != null) 'booking_time': bookingTime,
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (description != null) 'description': description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId)
        .select(_bookingSelect)
        .single();

    return BookingModel.fromJson(response);
  }

  Future<void> deleteBooking(int bookingId) async {
    await _supabase.from('bookings').delete().eq('id', bookingId);
  }

  Future<List<BookingModel>> getRecentBookings({int limit = 3}) async {
    final response = await _supabase
        .from('bookings')
        .select(_bookingSelect)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  Future<List<BookingModel>> getBookingsByStatus(String status) async {
    final response = await _supabase
        .from('bookings')
        .select(_bookingSelect)
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  Future<void> acceptBooking(int bookingId) async =>
      updateBookingStatus(bookingId: bookingId, status: 'Accepted');

  Future<void> rejectBooking(int bookingId) async =>
      updateBookingStatus(bookingId: bookingId, status: 'Rejected');

  Future<void> startBooking(int bookingId) async =>
      updateBookingStatus(bookingId: bookingId, status: 'InProgress');

  Future<void> completeBooking(int bookingId) async =>
      updateBookingStatus(bookingId: bookingId, status: 'Completed');

  Future<void> cancelBooking(int bookingId) async =>
      updateBookingStatus(bookingId: bookingId, status: 'Cancelled');
}
