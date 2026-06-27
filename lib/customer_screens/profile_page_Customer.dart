import 'package:fix_easy/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav_bar_customer.dart';
import 'update_profile_screen.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authRepo = AuthRepository();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepo.getUserInfo();
      if (mounted) setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _displayName {
    final first = _user?.firstName ?? '';
    final last = _user?.lastName ?? '';
    return [first, last].where((s) => s.isNotEmpty).join(' ');
  }

  String get _memberSince {
    final createdAtStr =
        Supabase.instance.client.auth.currentUser?.createdAt;
    if (createdAtStr == null) return '';
    return DateTime.tryParse(createdAtStr)?.toLocal().toString().split(' ')[0] ?? '';
  }

  Future<void> _logout() async {
    await _authRepo.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.grey[50],
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) _logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: (_user?.profileImage != null &&
                                    _user!.profileImage!.isNotEmpty)
                                ? NetworkImage(_user!.profileImage!)
                                : null,
                            child: (_user?.profileImage == null ||
                                    _user!.profileImage!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 50, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _displayName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email,
                                color: AppColors.primary),
                            title: const Text('Email'),
                            subtitle: Text(_user?.email ?? ''),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_user?.phoneNumber != null &&
                              _user!.phoneNumber!.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.phone,
                                  color: AppColors.primary),
                              title: const Text('Phone'),
                              subtitle: Text(_user!.phoneNumber!),
                              contentPadding: EdgeInsets.zero,
                            ),
                          if (_memberSince.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: AppColors.primary),
                              title: const Text('Member Since'),
                              subtitle: Text(_memberSince),
                              contentPadding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Actions',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(Icons.logout,
                                color: Colors.orange),
                            title: const Text('Logout'),
                            subtitle:
                                const Text('Sign out of your account'),
                            contentPadding: EdgeInsets.zero,
                            onTap: _showLogoutConfirmationDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateProfileScreen(
                              name: _displayName,
                              email: _user?.email ?? '',
                              phone: _user?.phoneNumber ?? '',
                              profilePicture: _user?.profileImage,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) _loadProfile();
                        });
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
    );
  }
}
