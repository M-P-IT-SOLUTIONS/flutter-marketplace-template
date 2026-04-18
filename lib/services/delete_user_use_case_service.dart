import 'package:randki/main.dart';
import 'package:randki/services/auth_service.dart';
import 'package:randki/services/chat_service.dart';
import 'package:randki/services/logger_service.dart';
import 'package:randki/services/user_service.dart';

/// Service for handling the user account deletion process.
/// Implements a "soft delete" by marking the user's account as deleted in the database
abstract class IDeleteUserUseCaseService {
  Future<void> softDeleteUserAccount();
}


/// Service for handling the user account deletion process.
/// Implements a "soft delete" by marking the user's account as deleted via Supabase
class DeleteUserUseCaseServiceSupabase implements IDeleteUserUseCaseService {
  final IUserService _userService;
  final IChatService _chatService;
  final IAuthService _authService;

  DeleteUserUseCaseServiceSupabase(this._userService, this._chatService, this._authService);

  @override
  Future<void> softDeleteUserAccount() async {
    try {
      final authUser = _userService.requireUser();
      final userId = authUser.id;

      await supabase
          .from(_userService.users)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', userId);

      await _chatService.deleteUserChats(userId);

      await _authService.logout();

      Log.info('Account has been marked as deleted (soft delete)');
    } catch (e) {
      Log.warning('Fail user\'s account soft delete : $e');
      rethrow;
    }
  }
}
