// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'MoneyMate';
  static const String appTagline = 'Know what is safe to spend today';
  static const String currencySymbol = '₹';
  static const String appVersion = '1.0.0';

  // Pay Cycle Options
  static const String payCycle1st = '1st of month';
  static const String payCycle15th = '15th of month';
  static const String payCycleCustom = 'Custom date';

  // Default Budget Settings
  static const int defaultBudgetCycleDays = 30;
  static const double defaultSavingsRate = 0.20; // 20%

  // Transaction Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Groceries',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health & Medical',
    'Education',
    'Utilities',
    'Fuel',
    'Personal Care',
    'Travel',
    'Electronics',
    'Home & Maintenance',
    'Gifts & Donations',
    'Investment',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment Returns',
    'Rental Income',
    'Bonus',
    'Gift',
    'Refund',
    'Other Income',
  ];

  static const List<String> allCategories = [
    ...expenseCategories,
    ...incomeCategories,
  ];

  // Category Icons (Material Icons names)
  static const Map<String, String> categoryIcons = {
    'Food & Dining': 'restaurant',
    'Groceries': 'local_grocery_store',
    'Transport': 'directions_bus',
    'Shopping': 'shopping_bag',
    'Entertainment': 'movie',
    'Health & Medical': 'local_hospital',
    'Education': 'school',
    'Utilities': 'power',
    'Fuel': 'local_gas_station',
    'Personal Care': 'spa',
    'Travel': 'flight',
    'Electronics': 'devices',
    'Home & Maintenance': 'home_repair_service',
    'Gifts & Donations': 'card_giftcard',
    'Investment': 'trending_up',
    'Other': 'more_horiz',
    'Salary': 'account_balance_wallet',
    'Freelance': 'work',
    'Business': 'business',
    'Investment Returns': 'bar_chart',
    'Rental Income': 'house',
    'Bonus': 'star',
    'Gift': 'redeem',
    'Refund': 'replay',
    'Other Income': 'attach_money',
  };

  // Shared Preferences Keys
  static const String prefIsFirstLaunch = 'is_first_launch';
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefAppLockEnabled = 'app_lock_enabled';
  static const String prefBiometricEnabled = 'biometric_enabled';
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserId = 'user_id';
  static const String prefLastSyncTime = 'last_sync_time';

  // Database
  static const String dbName = 'moneymate.db';
  static const int dbVersion = 1;

  // Notification Channels
  static const String notifChannelId = 'moneymate_channel';
  static const String notifChannelName = 'MoneyMate Alerts';
  static const String notifChannelDesc = 'Bill reminders and spending alerts';

  // Safe-to-Spend Thresholds
  static const double safeThreshold = 0.8;   // green below 80% spent
  static const double cautionThreshold = 1.0; // amber 80-100%
  // above 100% = red

  // Demo Data
  static const bool enableDemoData = true;

  // Platform Channel
  static const String smsChannelName = 'com.moneymate.app/sms';

  // Date Formats
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayShortDateFormat = 'dd MMM';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayMonthYearFormat = 'MMM yyyy';

  // Duplicate Detection
  static const int duplicateWindowHours = 24;
  static const double duplicateAmountTolerance = 0.01;

  // Confidence Score Thresholds
  static const double highConfidence = 0.85;
  static const double mediumConfidence = 0.60;
  static const double lowConfidence = 0.40;
}
