// lib/data/models/user_profile.dart

import 'package:uuid/uuid.dart';

enum AppLockType {
  none,
  biometric,
  pin,
}

class UserProfile {
  final String id;
  final String name;
  final int paydayOfMonth; // 1-31
  final String payCycle; // '1st', '15th', 'custom'
  final bool appLockEnabled;
  final AppLockType appLockType;
  final String themeMode; // 'light', 'dark', 'system'
  final bool notificationsEnabled;
  final int reminderDaysBefore; // Days before due date to remind
  final DateTime createdAt;
  final DateTime? lastBackupAt;

  UserProfile({
    String? id,
    required this.name,
    required this.paydayOfMonth,
    this.payCycle = '1st',
    this.appLockEnabled = false,
    this.appLockType = AppLockType.none,
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.reminderDaysBefore = 3,
    DateTime? createdAt,
    this.lastBackupAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    int? paydayOfMonth,
    String? payCycle,
    bool? appLockEnabled,
    AppLockType? appLockType,
    String? themeMode,
    bool? notificationsEnabled,
    int? reminderDaysBefore,
    DateTime? createdAt,
    DateTime? lastBackupAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      paydayOfMonth: paydayOfMonth ?? this.paydayOfMonth,
      payCycle: payCycle ?? this.payCycle,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockType: appLockType ?? this.appLockType,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'paydayOfMonth': paydayOfMonth,
      'payCycle': payCycle,
      'appLockEnabled': appLockEnabled ? 1 : 0,
      'appLockType': appLockType.toString().split('.').last,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'reminderDaysBefore': reminderDaysBefore,
      'createdAt': createdAt.toIso8601String(),
      'lastBackupAt': lastBackupAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    AppLockType lockType;
    switch (map['appLockType'] as String? ?? 'none') {
      case 'biometric':
        lockType = AppLockType.biometric;
        break;
      case 'pin':
        lockType = AppLockType.pin;
        break;
      default:
        lockType = AppLockType.none;
    }

    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      paydayOfMonth: map['paydayOfMonth'] as int,
      payCycle: map['payCycle'] as String? ?? '1st',
      appLockEnabled: (map['appLockEnabled'] as int? ?? 0) == 1,
      appLockType: lockType,
      themeMode: map['themeMode'] as String? ?? 'system',
      notificationsEnabled: (map['notificationsEnabled'] as int? ?? 1) == 1,
      reminderDaysBefore: map['reminderDaysBefore'] as int? ?? 3,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastBackupAt: map['lastBackupAt'] != null
          ? DateTime.parse(map['lastBackupAt'] as String)
          : null,
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'User',
      paydayOfMonth: 1,
      payCycle: '1st',
    );
  }
}
