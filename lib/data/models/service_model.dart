class ServiceModel {
  final int serviceId;
  final int companyId;
  final String serviceName;
  final String? serviceDescription;
  final double price;
  final String? serviceImage;
  final int categoryId;
  final String? categoryName;
  final bool isPublished;
  final ServiceRating? rating;
  final DateTime? createdAt;

  // Company info (when fetched with service)
  final String? companyName;
  final String? companyLogo;

  ServiceModel({
    required this.serviceId,
    required this.companyId,
    required this.serviceName,
    this.serviceDescription,
    required this.price,
    this.serviceImage,
    required this.categoryId,
    this.categoryName,
    this.isPublished = true,
    this.rating,
    this.createdAt,
    this.companyName,
    this.companyLogo,
  });

  String get imageUrl {
    if (serviceImage == null || serviceImage!.isEmpty) return '';
    return serviceImage!;
  }

  String get companyLogoUrl {
    if (companyLogo == null || companyLogo!.isEmpty) return '';
    return companyLogo!;
  }

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(0)}';

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle nested categories object from Supabase join
    final categoryData = json['categories'];
    final categoryName = categoryData is Map
        ? categoryData['name'] as String?
        : json['categoryName'] ?? json['serviceCategoryName'];

    // Handle nested company_profiles object from Supabase join
    final companyData = json['company_profiles'];
    final companyName = companyData is Map
        ? companyData['company_name'] as String?
        : json['companyName'];
    final companyLogo = companyData is Map
        ? companyData['logo'] as String?
        : json['companyLogo'];

    return ServiceModel(
      serviceId: json['id'] ?? json['serviceId'] ?? 0,
      companyId: json['company_id'] ?? json['companyId'] ?? 0,
      serviceName: json['name'] ?? json['serviceName'] ?? '',
      serviceDescription: json['description'] ?? json['serviceDescription'],
      price: (json['price'] ?? 0).toDouble(),
      serviceImage: json['image'] ?? json['serviceImage'],
      categoryId: json['category_id'] ?? json['categoryId'] ?? 0,
      categoryName: categoryName,
      isPublished: json['is_published'] ?? json['isPublished'] ?? false,
      rating: null, // Ratings computed separately from reviews
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      companyName: companyName,
      companyLogo: companyLogo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serviceId,
      'company_id': companyId,
      'name': serviceName,
      'description': serviceDescription,
      'price': price,
      'image': serviceImage,
      'category_id': categoryId,
      'is_published': isPublished,
    };
  }

  ServiceModel copyWith({
    int? serviceId,
    int? companyId,
    String? serviceName,
    String? serviceDescription,
    double? price,
    String? serviceImage,
    int? categoryId,
    String? categoryName,
    bool? isPublished,
    ServiceRating? rating,
    DateTime? createdAt,
    String? companyName,
    String? companyLogo,
  }) {
    return ServiceModel(
      serviceId: serviceId ?? this.serviceId,
      companyId: companyId ?? this.companyId,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      price: price ?? this.price,
      serviceImage: serviceImage ?? this.serviceImage,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isPublished: isPublished ?? this.isPublished,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
    );
  }
}

class ServiceRating {
  final double averageRating;
  final int totalRatings;

  ServiceRating({required this.averageRating, required this.totalRatings});

  String get formattedRating => averageRating.toStringAsFixed(1);

  factory ServiceRating.fromJson(Map<String, dynamic> json) {
    return ServiceRating(
      averageRating: (json['average_rating'] ?? json['averageRating'] as num?)
              ?.toDouble() ??
          0.0,
      totalRatings: json['total_ratings'] ?? json['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_ratings': totalRatings,
    };
  }
}

class ServiceCategory {
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;

  ServiceCategory({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      categoryId: json['id'] ?? json['categoryId'] ?? 0,
      categoryName: json['name'] ?? json['categoryName'] ?? '',
      categoryIcon: json['icon'] ?? json['categoryIcon'],
    );
  }
}
