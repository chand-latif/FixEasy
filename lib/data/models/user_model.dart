class UserModel {
  final String userId; // UUID from Supabase Auth
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String userType; // 'Customer' or 'Seller'
  final bool isEmailVerified;
  final bool isCompanyProfileExist;
  final int? companyId;
  final String? profileImage;

  UserModel({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.userType,
    this.isEmailVerified = false,
    this.isCompanyProfileExist = false,
    this.companyId,
    this.profileImage,
  });

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  bool get isCustomer => userType == 'Customer';
  bool get isSeller => userType == 'Seller';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      userType: json['user_type'] ?? json['userType'] ?? 'Customer',
      isEmailVerified: json['is_email_verified'] ?? json['isEmailVerified'] ?? false,
      isCompanyProfileExist: json['isCompanyProfileExist'] ?? false,
      companyId: json['companyId'],
      profileImage: json['profile_image'] ?? json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'profile_image': profileImage,
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? userType,
    bool? isEmailVerified,
    bool? isCompanyProfileExist,
    int? companyId,
    String? profileImage,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isCompanyProfileExist: isCompanyProfileExist ?? this.isCompanyProfileExist,
      companyId: companyId ?? this.companyId,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
