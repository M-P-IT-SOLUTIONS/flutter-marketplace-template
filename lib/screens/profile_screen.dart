import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:randki/core/user_result.dart';
import 'package:provider/provider.dart';
import 'package:randki/services/auth_service.dart';
import 'package:randki/l10n/app_localizations.dart';
import 'package:randki/services/delete_user_use_case_service.dart';
import 'package:randki/services/notifications_service.dart';
import 'package:randki/services/user_service.dart';
import 'package:randki/view_models/language_view_model.dart';
import 'package:randki/view_models/profile_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:randki/view_models/favorite_places_view_model.dart';
import 'package:randki/screens/favorite_places_screen.dart';
import 'package:randki/views/components/profile_avatar_widget.dart';
import 'package:randki/models/profile_preferences_enums.dart';
import 'package:randki/adapters/app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:randki/view_models/theme_view_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:permission_handler/permission_handler.dart'
    show
        Permission,
        PermissionActions,
        PermissionCheckShortcuts,
        PermissionStatusGetters,
        openAppSettings;

/// Profile screen displaying user information and preferences
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(showTitle: true, showMenu: true),
      body: ListView(
        padding: const EdgeInsets.all(27),
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 94, 0.1),
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Consumer<ProfileViewModel>(
                  builder: (context, profileVM, _) {
                    final user = profileVM.currentUser;
                    final isLoading = profileVM.isLoading;
                    final name =
                        isLoading
                            ? '…'
                            : (user?.nickname.isNotEmpty == true
                                ? user!.nickname
                                : '—');
                    // Dynamic role label based on isPremium.
                    // We use a simple ‘User’ fallback if not premium.
                    final roleLabel =
                        user == null
                            ? ''
                            : (user.isPremium
                                ? AppLocalizations.of(context)!.premium_user
                                : 'User');
                    return Stack(
                      children: [
                        Skeletonizer(
                          enabled: isLoading,
                          child: _ProfileHeader(
                            name: name,
                            role: roleLabel,
                            progress: 0.68,
                            future: Future.value(const UserSuccess()),
                            avatarUrl: user?.avatarUrl,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              Symbols.edit_square,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => Consumer<ProfileViewModel>(
                                      builder:
                                          (_, vm, __) => ProfileEditDialog(
                                            avatarUrl:
                                                vm.currentUser?.avatarUrl,
                                          ),
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          //ulubione
          Container(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 94, 0.1),
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<FavoritePlacesViewModel>(
                    builder:
                        (context, favVM, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                                top: 0,
                                bottom: 0,
                              ),
                              child: Icon(
                                Icons.favorite_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.favourite_places}: ${favVM.favoritesCount}',
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 24,
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (favVM.isLoading)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  top: 0,
                                  bottom: 0,
                                ),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FavoritePlacesScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.view_favourite_places,
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          //preferencje
          Container(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 94, 0.1),
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: _SectionTitle(
                    title: AppLocalizations.of(context)!.preferences,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: const Color.fromRGBO(195, 196, 215, 1),
                ),
                PreferencesSection(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          //aktywność
          Container(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 94, 0.1),
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: _SectionTitle(
                    title: AppLocalizations.of(context)!.activity,
                  ),
                ),
                Divider(
                  height: 5,
                  thickness: 0.5,
                  color: const Color.fromRGBO(195, 196, 215, 1),
                ),
                _ActivityTile(
                  label: AppLocalizations.of(context)!.active_days,
                  value:
                      context
                          .watch<ProfileViewModel>()
                          .activeDays
                          ?.toString() ??
                      '—',
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          //przycisk wyloguj się
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _BottomProfileButton(
                  title: AppLocalizations.of(context)!.delete_account,
                  color: const Color.fromRGBO(255, 59, 48, 1),
                  onPressed: () async {
                    await context.read<IDeleteUserUseCaseService>().softDeleteUserAccount();
                  },
                  icon: Icons.delete_outlined,
                  confirmationRequired: true,
                ),
                _BottomProfileButton(
                  title: AppLocalizations.of(context)!.log_out,
                  color: const Color.fromRGBO(16, 20, 94, 1),
                  onPressed: () async {
                    await context.read<IAuthService>().logout();
                  },
                  icon: Icons.logout_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// Button used at the bottom of the profile screen for actions like logout or delete account
class _BottomProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String title;
  final Color color;
  final bool confirmationRequired;

  const _BottomProfileButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.color,
    this.confirmationRequired = false,
  });

  _showConfirmationDialog(VoidCallback onConfirmed, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirm_action),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmed();
                },
                child: Text(
                  AppLocalizations.of(context)!.yes,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          confirmationRequired
              ? () => _showConfirmationDialog(onPressed, context)
              : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 5, top: 0, bottom: 0),
            child: Icon(
              icon,
              color: Color.fromRGBO(255, 255, 255, 1),
              size: 22,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile header widget displaying user's name, role, progress, and avatar
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final double progress;
  final Future<UserResult> future;
  final String? avatarUrl; // URL of the user's avatar

  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.progress,
    required this.future,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            // User's avatar
            ProfileAvatarWidget(avatarUrl: avatarUrl),
            const SizedBox(width: 17),
            // User profile data
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 30, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tile representing a user preference with an icon, label, and optional trailing widget
class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _PreferenceTile({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5, top: 0, bottom: 0),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Mplus1p',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Tile representing a user activity metric with an icon, label, and value
class _ActivityTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ActivityTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5, top: 0, bottom: 0),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Mplus1p',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Title widget for sections in the profile screen
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Mplus1p',
        fontSize: 24,
        letterSpacing: -1,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Section for managing user preferences such as language, theme, and notifications
class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  AppLanguage selectedLanguage = AppLanguage.pl;
  AppThemeMode selectedTheme = AppThemeMode.automatic;
  bool notificationsEnabled = false;
  String? userId;
  late final INotificationsService _notificationsService;

  /// Check if notification permission is granted
  Future<bool> _hasNotificationPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (Platform.isAndroid) {
      if (await Permission.notification.isGranted) return true;
      return false;
    }

    return true;
  }

  /// Request notification permission from the user
  Future<bool> _requestNotificationPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted || status.isLimited;
    }

    return true;
  }

  /// Handle toggling of notification preference
  Future<void> onToggleNotifications(bool value) async {
    if (value) {
      final granted = await _requestNotificationPermission();
      if (!granted) {
        if (mounted) setState(() => notificationsEnabled = false);
        await openAppSettings(); // opcjonalnie
        return;
      }

      await _notificationsService.saveFcmTokenToSupabase(userId!);

      if (mounted) setState(() => notificationsEnabled = true);
    } else {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}

      await _notificationsService.removeFcmTokenFromSupabase(userId!);
      if (mounted) setState(() => notificationsEnabled = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    userId = context.read<IUserService>().getCurrentUserId();
    _notificationsService = context.read<INotificationsService>();
  }

  /// Initialize notification settings based on current permissions and Supabase token status
  Future<void> _initializeNotifications() async {
    final hasPermission = await _hasNotificationPermission();
    final hasToken = await _notificationsService.hasTokenInSupabase(userId!);

    if (mounted) {
      setState(() {
        notificationsEnabled = hasPermission && hasToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageViewModel = Provider.of<LanguageViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    // Detecting the current language
    selectedLanguage = AppLanguageExtension.fromCode(
      Localizations.localeOf(context).languageCode,
    );

    selectedTheme = themeViewModel.mode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          _PreferenceTile(
            icon: Icons.language,
            label: AppLocalizations.of(context)!.language,
            trailing: PopupMenuButton<AppLanguage>(
              color: Theme.of(context).colorScheme.surface,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) {
                setState(() => selectedLanguage = value);
                languageViewModel.changeLocale(value.code);
              },
              itemBuilder:
                  (_) => [
                    for (final lang in AppLanguage.values)
                      _popupItem(lang.label, selectedLanguage.label, lang),
                  ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage.label,
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          //choosing theme
          _PreferenceTile(
            icon: Symbols.routine,
            label: AppLocalizations.of(context)!.theme,
            trailing: PopupMenuButton<AppThemeMode>(
              color: Theme.of(context).colorScheme.surface,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) {
                setState(() => selectedTheme = value);
                themeViewModel.setMode(value);
              },
              itemBuilder:
                  (_) => [
                    for (final mode in AppThemeMode.values)
                      _popupItem(
                        mode.label(context),
                        selectedTheme.label(context),
                        mode,
                      ),
                  ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedTheme.label(context),
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          _PreferenceTile(
            icon: Icons.notifications_outlined,
            label: AppLocalizations.of(context)!.notifications,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  notificationsEnabled
                      ? AppLocalizations.of(context)!.on
                      : AppLocalizations.of(context)!.off,
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(
                  height: 22,
                  width: 30,
                  child: Transform.scale(
                    scale: 0.4,
                    child: Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: notificationsEnabled,
                      onChanged: onToggleNotifications,
                      activeColor: Theme.of(context).colorScheme.tertiary,
                      activeTrackColor: const Color.fromRGBO(210, 210, 211, 1),
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.tertiary,
                      inactiveTrackColor: const Color.fromRGBO(
                        210,
                        210,
                        211,
                        1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<T> _popupItem<T>(String label, String selectedLabel, T value) {
    return PopupMenuItem<T>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (label == selectedLabel) const SizedBox(width: 8),
          if (label == selectedLabel) const Icon(Icons.check, size: 15),
        ],
      ),
    );
  }
}

class ProfileEditDialog extends StatefulWidget {
  final String? avatarUrl;

  const ProfileEditDialog({super.key, this.avatarUrl});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _nickController;
  Uint8List? _pendingAvatarBytes;
  String? _pendingAvatarExt;
  bool _deleteAvatar = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    _nickController = TextEditingController(
      text: vm.currentUser?.nickname ?? '',
    );
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 390;
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20 * textScale,
          right: 20 * textScale,
          top: 10,
          bottom: 35,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 20 * textScale),
                IgnorePointer(
                  child: Text(
                    AppLocalizations.of(context)!.edit_profile,
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 24 * textScale,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: IconTheme(
                    data: IconThemeData(
                      color: Theme.of(context).colorScheme.primary,
                      size: 30 * textScale,
                    ),
                    child: Icon(Icons.close),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * textScale),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Color.fromRGBO(195, 196, 215, 1),
            ),
            SizedBox(height: 10 * textScale),
            Text(
              AppLocalizations.of(context)!.profile_picture,
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 20 * textScale,
                letterSpacing: -1,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 9 * textScale,
                right: 9 * textScale,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  ProfileAvatarWidget(
                    avatarUrl: _deleteAvatar ? null : widget.avatarUrl,
                    avatarBytes: _pendingAvatarBytes,
                    radius: screenWidth < 370 ? 29 : (38 * textScale),
                  ),
                  SizedBox(width: 12 * textScale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //przycisk zmień zdjęcie
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: SizedBox(
                            height: 36,
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final XFile? picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  imageQuality: 85,
                                );
                                if (picked != null) {
                                  final bytes = await picked.readAsBytes();
                                  final ext =
                                      picked.name.split('.').last.toLowerCase();
                                  if (!mounted) return;
                                  setState(() {
                                    _pendingAvatarBytes = bytes;
                                    _pendingAvatarExt = ext;
                                    _deleteAvatar =
                                        false; // nadpisujemy usunięcie
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * textScale,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                    size: 22 * textScale,
                                  ),
                                  SizedBox(width: 5 * textScale),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.change_picture,
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //przycisk usuń zdjęcie
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: SizedBox(
                            height: 36,
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () async {
                                if (!mounted) return;
                                setState(() {
                                  _pendingAvatarBytes = null;
                                  _pendingAvatarExt = null;
                                  _deleteAvatar = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Color.fromRGBO(246, 71, 64, 1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * textScale,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Symbols.delete,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                    size: 22 * textScale,
                                  ),
                                  SizedBox(width: 5 * textScale),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.delete_picture,
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            //nazwa użytkownika
            Text(
              AppLocalizations.of(context)!.username,
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 20 * textScale,
                letterSpacing: -1,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15 * textScale),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: _nickController,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 16 * textScale,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28 * textScale,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 2,
                            height: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    hintText: AppLocalizations.of(context)!.set_nickname,
                    hintStyle: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // przycisk zapisu
            Center(
              child: Consumer<ProfileViewModel>(
                builder:
                    (context, vm, _) => TextButton(
                      onPressed:
                          vm.isSaving
                              ? null
                              : () async {
                                bool ok = true;
                                final newNick = _nickController.text.trim();
                                final currentNick =
                                    vm.currentUser?.nickname.trim() ?? '';

                                if (newNick.isNotEmpty &&
                                    newNick != currentNick) {
                                  ok = await vm.changeNickname(newNick);
                                }

                                if (ok && _pendingAvatarBytes != null) {
                                  ok = await vm.uploadAvatar(
                                    _pendingAvatarBytes!,
                                    _pendingAvatarExt ?? 'jpg',
                                  );
                                } else if (ok && _deleteAvatar) {
                                  ok = await vm.deleteAvatar();
                                }

                                if (!mounted) return;
                                if (ok) Navigator.of(context).pop();
                              },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (vm.isSaving)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                              top: 0,
                              bottom: 0,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 22,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.save_changes,
                            style: TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
