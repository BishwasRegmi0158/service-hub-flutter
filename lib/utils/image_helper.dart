import 'dart:convert';
import 'package:flutter/material.dart';

// Photos are stored as base64 data URIs now (picked from gallery), but
// the RandomUser.me demo professionals still have plain network URLs —
// this handles both so nothing breaks.
ImageProvider? professionalImageProvider(String photoUrl) {
  if (photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('data:image')) {
    try {
      return MemoryImage(base64Decode(photoUrl.split(',').last));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(photoUrl);
}

Widget professionalPhotoWidget(
  String photoUrl, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
}) {
  final provider = professionalImageProvider(photoUrl);
  final fallback = Container(
    height: height,
    width: width,
    color: Colors.grey[200],
    alignment: Alignment.center,
    child: const Icon(Icons.person_outline, size: 60),
  );
  if (provider == null) return fallback;
  return Image(image: provider, height: height, width: width, fit: fit, errorBuilder: (_, __, ___) => fallback);
}