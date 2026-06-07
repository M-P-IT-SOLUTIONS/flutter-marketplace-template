import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Redirects to mail with pre-filled address and subject
Future<void> goToMail(
  String email,
  BuildContext context, {
  String subject = "",
}) async {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters(<String, String>{'subject': subject}),
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw Exception('Cannot open mail: $emailUri');
  }
}

/// Redirects to external link
Future<void> runUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Cannot open link: $url');
  }
}

/// Formats Duration into readable text
String formatDuration(Duration d) {
  final parts = <String>[];
  if (d.inDays >= 2) parts.add('${d.inDays} days');
  if (d.inDays == 1) parts.add('1 day');
  final hours = d.inHours % 24;
  if (hours > 0) parts.add('${hours}h');
  final minutes = d.inMinutes % 60;
  if (minutes > 0) parts.add('${minutes}min');
  final seconds = d.inSeconds % 60;
  if (seconds > 0) parts.add('${seconds}s');
  if (parts.isEmpty) return '0min';
  return parts.join(' ');
}

/// Attempts to display permission dialog for user location access.
/// Returns true if SnackBar with location permission denied is shown, false otherwise.
Future<bool> checkAndShowUserLocationPermissionDenied({
  required FilterViewModel filterVM,
  required PlacesModel placesModel,
  required BuildContext context,
}) async {
  // If no custom location, fetch or update user location
  if (filterVM.searchNearbyUser == null || filterVM.searchNearbyUser == true) {
    placesModel.setIsLoading(true);
    await placesModel.updateUserMarker();
    placesModel.setIsLoading(false);
    // If failed, show error message
    if (filterVM.userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.allow_location_access_or_set_another,
          ),
        ),
      );
      return true;
    } else {
      return false;
    }
  }
  return false;
}

/// Higher-order function that handles retrying function calls with exponentially increasing delays
Future<T> retry<T>(Future<T> Function() op, {int attempts = 3}) async {
  for (var i = 0; i < attempts; i++) {
    try {
      return await op();
    } catch (e) {
      final isLast = i == attempts - 1;
      if (isLast) rethrow;
      await Future.delayed(Duration(milliseconds: 200 * (1 << i)));
    }
  }
  throw StateError('retry unreachable');
}
