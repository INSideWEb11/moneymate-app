// lib/presentation/providers/user_profile_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/budget_repository.dart';

class UserProfileProvider extends ChangeNotifier {
  final BudgetRepository _repo;

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfileProvider({BudgetRepository? repo})
      : _repo = repo ?? BudgetRepository();

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  String get name => _profile?.name ?? 'User';
  int get paydayOfMonth => _profile?.paydayOfMonth ?? 1;
  String get themeMode => _profile?.themeMode ?? 'system';
  bool get notificationsEnabled => _profile?.notificationsEnabled ?? true;
  bool get appLockEnabled => _profile?.appLockEnabled ?? false;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repo.getUserProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repo.updateUserProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(name: name);
    await saveProfile(updated);
  }

  Future<void> updateTheme(String mode) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(themeMode: mode);
    await saveProfile(updated);
  }

  Future<void> updateNotifications(bool enabled) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(notificationsEnabled: enabled);
    await saveProfile(updated);
  }

  Future<void> updateAppLock(bool enabled, AppLockType type) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      appLockEnabled: enabled,
      appLockType: type,
    );
    await saveProfile(updated);
  }

  Future<void> updatePayday(int day) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(paydayOfMonth: day);
    await saveProfile(updated);
  }
}
