//zdjęcie użytkownika
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A widget that displays a user's profile avatar, supporting both network images and local byte previews.
class ProfileAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final Uint8List? avatarBytes; // optional local preview bytes
  final double radius;
  bool selected;

  ProfileAvatarWidget({
    super.key,
    required this.avatarUrl,
    this.avatarBytes,
    this.radius = 36,
    this.selected = false
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider =
        avatarBytes != null
            ? MemoryImage(avatarBytes!)
            : (avatarUrl != null ? NetworkImage(avatarUrl!) : null);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        backgroundImage: imageProvider,
        child:
            imageProvider == null
                ? Icon(
                  Icons.person,
                  size: radius / 36 * 65,
                  color: const Color.fromRGBO(210, 210, 211, 1),
                )
                : null,
      ),
    );
  }
}