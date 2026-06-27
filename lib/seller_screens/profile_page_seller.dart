import 'package:fix_easy/theme.dart';
import 'package:flutter/material.dart';
import 'update_company_profile.dart';
import 'nav_bar_seller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/company_model.dart';

class ProfilePageSeller extends StatefulWidget {
  ProfilePageSeller({super.key});

  @override
  State<ProfilePageSeller> createState() => _ProfilePageSellerState();
}

class _ProfilePageSellerState extends State<ProfilePageSeller> {
  final _authRepo = AuthRepository();
  final _companyRepo = CompanyRepository();

  UserModel? _user;
  CompanyModel? _company;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepo.getUserInfo();
      setState(() => _user = user);

      if (user.companyId != null) {
        final company =
            await _companyRepo.getCompanyProfile(user.companyId!);
        setState(() {
          _company = company;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigate() {
    if (_user?.companyId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UpdateCompanyProfileScreen(companyId: _user!.companyId!),
      ),
    ).then((value) {
      if (value == true) _loadProfile();
    });
  }

  Future<void> _logout() async {
    await _authRepo.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  String get _displayName {
    final first = _user?.firstName ?? '';
    final last = _user?.lastName ?? '';
    return [first, last].where((s) => s.isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.cyan, Colors.teal],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: (_company?.companyLogo != null &&
                                    _company!.companyLogo!.isNotEmpty)
                                ? NetworkImage(_company!.companyLogo!)
                                : null,
                            child: (_company?.companyLogo == null ||
                                    _company!.companyLogo!.isEmpty)
                                ? const Icon(Icons.business,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _displayName.isEmpty
                                ? (_company?.companyName ?? '')
                                : _displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Info
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Account Information',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Divider(height: 24),
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.email,
                                        color: AppColors.primary),
                                  ),
                                  title: const Text('Email'),
                                  subtitle: Text(_user?.email ?? ''),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (_user?.phoneNumber != null)
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(Icons.phone,
                                          color: AppColors.primary),
                                    ),
                                    title: const Text('Phone'),
                                    subtitle: Text(_user!.phoneNumber!),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Company Info Card
                        if (_company != null)
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Company Information',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Divider(height: 24),
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(Icons.business,
                                          color: AppColors.primary),
                                    ),
                                    title: const Text('Company Name'),
                                    subtitle: Text(_company!.companyName),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (_company!.companyAddress != null &&
                                      _company!.companyAddress!.isNotEmpty)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.location_on,
                                            color: AppColors.primary),
                                      ),
                                      title: const Text('Address'),
                                      subtitle: Text(_company!.companyAddress!),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  if (_company!.companyPhone != null &&
                                      _company!.companyPhone!.isNotEmpty)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.phone,
                                            color: AppColors.primary),
                                      ),
                                      title: const Text('Phone'),
                                      subtitle: Text(_company!.companyPhone!),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  if (_company!.companyEmail != null &&
                                      _company!.companyEmail!.isNotEmpty)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.email,
                                            color: AppColors.primary),
                                      ),
                                      title: const Text('Company Email'),
                                      subtitle: Text(_company!.companyEmail!),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: _navigate,
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Company Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: NavBarSeller(currentIndex: 3),
    );
  }
}
