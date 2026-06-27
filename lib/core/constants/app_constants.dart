/// App-wide constants for the FixEasy app.

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// App name
  static const String appName = 'FixEasy';

  /// App tagline
  static const String appTagline = 'Your Home Service Partner';

  /// User types
  static const String customerType = 'Customer';
  static const String sellerType = 'Seller';

  /// Booking statuses
  static const String statusPending = 'Pending';
  static const String statusAccepted = 'Accepted';
  static const String statusInProgress = 'InProgress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
  static const String statusRejected = 'Rejected';

  /// Service categories (matching Supabase seeded IDs)
  static const Map<String, int> categoryIds = {
    'Plumbing': 1,
    'Electrical': 2,
    'Cleaning': 3,
    'Painting': 4,
    'Carpentry': 5,
    'AC & Appliances': 6,
    'Pest Control': 7,
    'Shifting & Moving': 8,
  };

  /// Animation durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
