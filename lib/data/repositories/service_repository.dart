import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';

class ServiceRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<ServiceModel>> getPublishedServices(int companyId) async {
    final response = await _supabase
        .from('services')
        .select('*, categories(name), company_profiles(company_name, logo)')
        .eq('company_id', companyId)
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  Future<List<ServiceModel>> getAllCompanyServices(int companyId) async {
    final response = await _supabase
        .from('services')
        .select('*, categories(name), company_profiles(company_name, logo)')
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  Future<List<ServiceModel>> getServicesByCategory(int categoryId) async {
    final response = await _supabase
        .from('services')
        .select('*, categories(name), company_profiles(company_name, logo)')
        .eq('category_id', categoryId)
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  Future<List<ServiceModel>> getAllPublishedServices() async {
    final response = await _supabase
        .from('services')
        .select('*, categories(name), company_profiles(company_name, logo)')
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  Future<ServiceModel> createService({
    required int companyId,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int categoryId,
    bool isPublished = true,
  }) async {
    final response = await _supabase
        .from('services')
        .insert({
          'company_id': companyId,
          'name': serviceName,
          'description': serviceDescription,
          'price': price,
          'category_id': categoryId,
          'is_published': isPublished,
        })
        .select('*, categories(name), company_profiles(company_name, logo)')
        .single();

    return ServiceModel.fromJson(response);
  }

  Future<ServiceModel> updateService({
    required int serviceId,
    String? serviceName,
    String? serviceDescription,
    double? price,
    int? categoryId,
    bool? isPublished,
  }) async {
    final response = await _supabase
        .from('services')
        .update({
          if (serviceName != null) 'name': serviceName,
          if (serviceDescription != null) 'description': serviceDescription,
          if (price != null) 'price': price,
          if (categoryId != null) 'category_id': categoryId,
          if (isPublished != null) 'is_published': isPublished,
        })
        .eq('id', serviceId)
        .select('*, categories(name), company_profiles(company_name, logo)')
        .single();

    return ServiceModel.fromJson(response);
  }

  Future<void> deleteService(int serviceId) async {
    await _supabase.from('services').delete().eq('id', serviceId);
  }

  Future<void> uploadServiceImage({
    required int serviceId,
    required String imagePath,
  }) async {
    final file = File(imagePath);
    final fileName = '${serviceId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$serviceId/$fileName';

    await _supabase.storage
        .from('service-images')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _supabase.storage
        .from('service-images')
        .getPublicUrl(storagePath);

    await _supabase
        .from('services')
        .update({'image': publicUrl})
        .eq('id', serviceId);
  }

  Future<List<ReviewModel>> getServiceReviews(int serviceId) async {
    final response = await _supabase
        .from('reviews')
        .select('*, profiles(first_name, last_name, profile_image)')
        .eq('service_id', serviceId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  Future<void> createReview({
    required int serviceId,
    required int bookingId,
    required double rating,
    String? comment,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('reviews').insert({
      'service_id': serviceId,
      'booking_id': bookingId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<ServiceCategory>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select('*')
        .order('id');

    return (response as List)
        .map((json) => ServiceCategory.fromJson(json))
        .toList();
  }
}
