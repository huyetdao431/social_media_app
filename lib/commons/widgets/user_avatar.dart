import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget userAvatar(String? avatarUrl) {
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[300], width: 44, height: 44),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 32)),
      ),
    );
  }
  return Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black));
}