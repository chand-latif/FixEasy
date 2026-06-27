import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_model.dart';

class CompanyRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<CompanyModel>> getAllCompanies() async {
    final response = await _supabase
        .from('company_profiles')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CompanyModel.fromJson(json))
        .toList();
  }

  Future<CompanyModel> getCompanyProfile(int companyId) async {
    final response = await _supabase
        .from('company_profiles')
        .select('*')
        .eq('id', companyId)
        .single();

    return CompanyModel.fromJson(response);
  }

  Future<CompanyModel> createCompanyProfile({
    required String companyName,
    String? companyDescription,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    double? latitude,
    double? longitude,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('company_profiles')
        .insert({
          'user_id': userId,
          'company_name': companyName,
          'description': companyDescription,
          'address': companyAddress,
          'phone': companyPhone,
          'email': companyEmail,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  Future<CompanyModel> updateCompanyProfile({
    required int companyId,
    String? companyName,
    String? companyDescription,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _supabase
        .from('company_profiles')
        .update({
          if (companyName != null) 'company_name': companyName,
          if (companyDescription != null) 'description': companyDescription,
          if (companyAddress != null) 'address': companyAddress,
          if (companyPhone != null) 'phone': companyPhone,
          if (companyEmail != null) 'email': companyEmail,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  Future<void> uploadCompanyLogo({
    required int companyId,
    required String logoPath,
  }) async {
    final file = File(logoPath);
    final fileName = '${companyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$companyId/$fileName';

    await _supabase.storage
        .from('company-logos')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _supabase.storage
        .from('company-logos')
        .getPublicUrl(storagePath);

    await _supabase
        .from('company_profiles')
        .update({'logo': publicUrl})
        .eq('id', companyId);
  }

  Future<List<CompanyModel>> getFeaturedCompanies({int limit = 3}) async {
    final companies = await getAllCompanies();
    companies.sort((a, b) => b.totalRatings.compareTo(a.totalRatings));
    return companies.take(limit).toList();
  }
}
