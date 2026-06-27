class CompanyModel {
  final int companyId;
  final String userId; // UUID
  final String companyName;
  final String? companyDescription;
  final String? companyLogo;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyEmail;
  final double? latitude;
  final double? longitude;
  final int? servicesCount;
  final double averageRating;
  final int totalRatings;
  final DateTime? createdAt;

  CompanyModel({
    required this.companyId,
    required this.userId,
    required this.companyName,
    this.companyDescription,
    this.companyLogo,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.latitude,
    this.longitude,
    this.servicesCount,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.createdAt,
  });

  String get logoUrl {
    if (companyLogo == null || companyLogo!.isEmpty) return '';
    return companyLogo!;
  }

  String get formattedRating => averageRating.toStringAsFixed(1);

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['id'] ?? json['companyId'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? '',
      companyName: json['company_name'] ?? json['companyName'] ?? '',
      companyDescription: json['description'] ?? json['companyDescription'],
      companyLogo: json['logo'] ?? json['companyLogo'],
      companyAddress: json['address'] ?? json['companyAddress'],
      companyPhone: json['phone'] ?? json['companyPhone'],
      companyEmail: json['email'] ?? json['companyEmail'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      servicesCount: json['servicesCount'],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': companyId,
      'user_id': userId,
      'company_name': companyName,
      'description': companyDescription,
      'logo': companyLogo,
      'address': companyAddress,
      'phone': companyPhone,
      'email': companyEmail,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  CompanyModel copyWith({
    int? companyId,
    String? userId,
    String? companyName,
    String? companyDescription,
    String? companyLogo,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    double? latitude,
    double? longitude,
    int? servicesCount,
    double? averageRating,
    int? totalRatings,
    DateTime? createdAt,
  }) {
    return CompanyModel(
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyDescription: companyDescription ?? this.companyDescription,
      companyLogo: companyLogo ?? this.companyLogo,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      servicesCount: servicesCount ?? this.servicesCount,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
