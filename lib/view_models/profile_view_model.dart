import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/models/app_user.dart';
import 'package:flutter_marketplace_template/core/user_result.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_marketplace_template/utils/validators.dart';
import 'dart:typed_data';

class ProfileViewModel extends ChangeNotifier {
  final IUserService _userService;

  AppUser? _currentUser;
  bool _loading = false;
  String? _error;
  bool _saving = false;
  int? _activeDays;

  ProfileViewModel(this._userService) {
    // Listen for authentication state changes – reload profile or clear it.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        loadCurrentUser();
      } else {
        clear();
      }
    });

    // Initial user fetch on app startup (if already logged in),
    // to immediately display data on screens.
    if (Supabase.instance.client.auth.currentUser != null) {
      // Fire-and-forget; we don't wait in the constructor.
      // ignore: discarded_futures
      loadCurrentUser();
    }
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  bool get isSaving => _saving;
  bool get isPremium => _currentUser?.isPremium ?? false;
  int? get activeDays => _activeDays;

  Future<void> loadCurrentUser() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _userService.getUser();
    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;
        _recomputeActiveDays();
        _error = null;
        break;
      case UserSuccess():
        break;
      case UserError(:final errorMessage):
        _error = errorMessage;
        _currentUser = null;
        _activeDays = null;
        break;
    }
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Changes the user's nickname in the database and refreshes the profile in memory.
  Future<bool> changeNickname(String nickname) async {
    final trimmed = nickname.trim();
    final validation = Validators.validateNickname(trimmed);
    if (validation is ValidationError) {
      _error = validation.message;
      notifyListeners();
      return false;
    }

    _saving = true;
    _error = null;
    notifyListeners();

    final result = await _userService.changeUserNickname(trimmed);
    switch (result) {
      case UserSuccess():
        await loadCurrentUser();
        _saving = false;
        notifyListeners();
        return true;
      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();
        return false;
      default:
        _saving = false;
        notifyListeners();
        return false;
    }
  }

  /// Uploads a new avatar photo and refreshes the user model.
  Future<bool> uploadAvatar(Uint8List bytes, String fileExt) async {
    _saving = true;
    _error = null;
    notifyListeners();

    final result = await _userService.uploadAvatarFromBytes(bytes, fileExt);
    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;
        _recomputeActiveDays();
        _saving = false;
        notifyListeners();
        return true;
      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();
        return false;
      default:
        _saving = false;
        notifyListeners();
        return false;
    }
  }

  /// Deletes the avatar photo and refreshes the user model.
  Future<bool> deleteAvatar() async {
    _saving = true;
    _error = null;
    notifyListeners();

    final result = await _userService.deleteAvatar();
    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;
        _recomputeActiveDays();
        _saving = false;
        notifyListeners();
        return true;
      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();
        return false;
      default:
        _saving = false;
        notifyListeners();
        return false;
    }
  }

  /// Sets the user's premium status.
  Future<bool> setPremium(bool premium) async {
    _saving = true;
    _error = null;
    notifyListeners();
    final result = await _userService.changePremiumStatus(premium);
    switch (result) {
      case UserSuccess():
        await loadCurrentUser();
        _saving = false;
        notifyListeners();
        return true;
      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();
        return false;
      default:
        _saving = false;
        notifyListeners();
        return false;
    }
  }

  void _recomputeActiveDays() {
    final created = _currentUser?.createdAt;
    if (created == null) {
      _activeDays = null;
      return;
    }
    // Count full days from midnight of the creation date to now, inclusive of the first day.
    final start = DateTime(created.year, created.month, created.day);
    final now = DateTime.now();
    _activeDays = now.difference(start).inDays + 1;
  }
}
