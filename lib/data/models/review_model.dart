class ReviewModel {
  final int reviewId;
  final int serviceId;
  final String userId; // UUID
  final int bookingId;
  final double rating;
  final String? comment;
  final DateTime? createdAt;

  // User info (when fetched with review)
  final String? userName;
  final String? userImage;

  ReviewModel({
    required this.reviewId,
    required this.serviceId,
    required this.userId,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.userName,
    this.userImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profiles object from Supabase join
    final profileData = json['profiles'];
    final String? firstName = profileData is Map
        ? profileData['first_name'] as String?
        : null;
    final String? lastName = profileData is Map
        ? profileData['last_name'] as String?
        : null;
    final userName = (firstName != null || lastName != null)
        ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
        : json['userName'] ?? json['reviewerName'];
    final userImage = profileData is Map
        ? profileData['profile_image'] as String?
        : json['userImage'] ?? json['reviewerImage'];

    return ReviewModel(
      reviewId: json['id'] ?? json['reviewId'] ?? 0,
      serviceId: json['service_id'] ?? json['serviceId'] ?? 0,
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      bookingId: json['booking_id'] ?? json['bookingId'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      userName: userName,
      userImage: userImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }

  ReviewModel copyWith({
    int? reviewId,
    int? serviceId,
    String? userId,
    int? bookingId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userName,
    String? userImage,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
    );
  }
}
