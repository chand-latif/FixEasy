import 'package:flutter/material.dart';
import '../theme.dart';
import 'company_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../data/repositories/company_repository.dart';
import '../data/models/company_model.dart';

class AllCompaniesScreen extends StatefulWidget {
  const AllCompaniesScreen({super.key});

  @override
  State<AllCompaniesScreen> createState() => _AllCompaniesScreenState();
}

class _AllCompaniesScreenState extends State<AllCompaniesScreen> {
  final _companyRepo = CompanyRepository();
  bool isLoading = true;
  List<CompanyModel> companies = [];

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    try {
      final result = await _companyRepo.getAllCompanies();
      if (mounted) {
        setState(() {
          companies = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load companies. Please check your internet connection and try again.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildCompanyShimmer() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 20, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('All Companies'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => _buildCompanyShimmer(),
            )
          : companies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No companies available yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchCompanies,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: companies.length,
                    itemBuilder: (context, index) {
                      final company = companies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CompanyDetailsScreen(
                                company: {
                                  'id': company.companyId,
                                  'companyId': company.companyId,
                                  'companyName': company.companyName,
                                  'companyLogo': company.companyLogo,
                                  'companyAddress': company.companyAddress,
                                  'companyPhone': company.companyPhone,
                                  'phoneNumber': company.companyPhone,
                                  'companyEmail': company.companyEmail,
                                  'description': company.companyDescription,
                                  'averageRating': company.averageRating,
                                  'totalRatings': company.totalRatings,
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: company.companyLogo != null &&
                                          company.companyLogo!.isNotEmpty
                                      ? Image.network(
                                          company.companyLogo!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.business,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        )
                                      : Icon(Icons.business,
                                          size: 40, color: Colors.grey[400]),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        company.companyName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (company.companyAddress != null &&
                                          company.companyAddress!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                company.companyAddress!,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 4),
                                      if (company.companyPhone != null &&
                                          company.companyPhone!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.phone,
                                                size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              company.companyPhone!,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          Text(
                                            ' ${company.averageRating.toStringAsFixed(1)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                          Text(
                                            ' (${company.totalRatings})',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
