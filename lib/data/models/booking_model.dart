class BookingModel {
  final int bookingId;
  final int serviceId;
  final String customerId; // UUID
  final int companyId;
  final String status;
  final DateTime bookingDate;
  final String? bookingTime;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final double? totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related data
  final String? serviceName;
  final String? serviceImage;
  final String? companyName;
  final String? companyLogo;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;

  BookingModel({
    required this.bookingId,
    required this.serviceId,
    required this.customerId,
    required this.companyId,
    required this.status,
    required this.bookingDate,
    this.bookingTime,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.serviceName,
    this.serviceImage,
    this.companyName,
    this.companyLogo,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
  });

  String get serviceImageUrl {
    if (serviceImage == null || serviceImage!.isEmpty) return '';
    return serviceImage!;
  }

  String get companyLogoUrl {
    if (companyLogo == null || companyLogo!.isEmpty) return '';
    return companyLogo!;
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isInProgress => status.toLowerCase() == 'inprogress';
  bool get isCompleted =>
      status.toLowerCase() == 'completed' || status.toLowerCase() == 'finished';
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle nested services object from Supabase join
    final serviceData = json['services'];
    final serviceName = serviceData is Map
        ? serviceData['name'] as String?
        : json['serviceName'];
    final serviceImage = serviceData is Map
        ? serviceData['image'] as String?
        : json['serviceImage'];

    // Handle nested company_profiles object
    final companyData = json['company_profiles'];
    final companyName = companyData is Map
        ? companyData['company_name'] as String?
        : json['companyName'];
    final companyLogo = companyData is Map
        ? companyData['logo'] as String?
        : json['companyLogo'];

    // Handle nested profiles object (customer info)
    final customerData = json['profiles'];
    final String? customerFirstName = customerData is Map
        ? customerData['first_name'] as String?
        : null;
    final String? customerLastName = customerData is Map
        ? customerData['last_name'] as String?
        : null;
    final customerName = (customerFirstName != null || customerLastName != null)
        ? '${customerFirstName ?? ''} ${customerLastName ?? ''}'.trim()
        : json['customerName'];
    final customerPhone = customerData is Map
        ? customerData['phone_number'] as String?
        : json['customerPhone'];

    return BookingModel(
      bookingId: json['id'] ?? json['bookingId'] ?? 0,
      serviceId: json['service_id'] ?? json['serviceId'] ?? 0,
      customerId: (json['customer_id'] ?? json['customerId'] ?? '').toString(),
      companyId: json['company_id'] ?? json['companyId'] ?? 0,
      status: json['status'] ?? 'Pending',
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      bookingTime: json['booking_time'] ?? json['bookingTime'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'],
      totalPrice: (json['total_price'] ?? json['totalPrice'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      serviceName: serviceName,
      serviceImage: serviceImage,
      companyName: companyName,
      companyLogo: companyLogo,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'booking_time': bookingTime,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    };
  }

  BookingModel copyWith({
    int? bookingId,
    int? serviceId,
    String? customerId,
    int? companyId,
    String? status,
    DateTime? bookingDate,
    String? bookingTime,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceName,
    String? serviceImage,
    String? companyName,
    String? companyLogo,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      customerId: customerId ?? this.customerId,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}

class BookingStats {
  final int pending;
  final int accepted;
  final int inProgress;
  final int completed;

  BookingStats({
    this.pending = 0,
    this.accepted = 0,
    this.inProgress = 0,
    this.completed = 0,
  });

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      pending: json['pending'] ?? 0,
      accepted: json['accepted'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}
