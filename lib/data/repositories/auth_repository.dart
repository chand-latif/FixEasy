import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Sign in failed');
    return await getUserInfo();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String userType,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'user_type': userType,
      },
    );
    if (response.user == null) throw Exception('Sign up failed');
  }

  Future<UserModel> getUserInfo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final data = await _supabase
        .from('profiles')
        .select('*, company_profiles(id)')
        .eq('id', user.id)
        .single();

    final companies = (data['company_profiles'] as List?) ?? [];
    final hasCompany = companies.isNotEmpty;
    final companyId = hasCompany ? companies.first['id'] as int : null;

    return UserModel(
      userId: user.id,
      email: user.email ?? '',
      firstName: data['first_name'],
      lastName: data['last_name'],
      phoneNumber: data['phone_number'],
      userType: data['user_type'] ?? 'Customer',
      isEmailVerified: user.emailConfirmedAt != null,
      isCompanyProfileExist: hasCompany,
      companyId: companyId,
      profileImage: data['profile_image'],
    );
  }

  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  bool isAuthenticated() {
    return _supabase.auth.currentSession != null;
  }

  String? getUserType() {
    return _supabase.auth.currentUser?.userMetadata?['user_type'] as String?;
  }

  bool isCustomer() => getUserType() == 'Customer';

  bool isSeller() => getUserType() == 'Seller';

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').update({
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    }).eq('id', userId);
  }

  Future<void> uploadAvatar({required String imagePath}) async {
    final userId = _supabase.auth.currentUser!.id;
    final file = File(imagePath);
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$userId/$fileName';

    await _supabase.storage
        .from('avatars')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl =
        _supabase.storage.from('avatars').getPublicUrl(storagePath);

    await _supabase
        .from('profiles')
        .update({'profile_image': publicUrl})
        .eq('id', userId);
  }
}
