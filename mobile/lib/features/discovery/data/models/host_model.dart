// lib/features/discovery/data/models/host_model.dart

import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';

class HostModel extends HostEntity {
  const HostModel({
    required String id,
    required String displayName,
    String? profilePhotoUrl,
    String? bio,
    required double audioCallRate,
    required double videoCallRate,
    required double messageRate,
    required String status,
    required bool isAvailable,
    Rating? rating,
  }) : super(
    id: id,
    displayName: displayName,
    profilePhotoUrl: profilePhotoUrl,
    bio: bio,
    audioCallRate: audioCallRate,
    videoCallRate: videoCallRate,
    messageRate: messageRate,
    status: status,
    isAvailable: isAvailable,
    rating: rating,
  );

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Unknown',
      profilePhotoUrl: json['profilePhotoUrl'],
      bio: json['bio'],
      audioCallRate: (json['audioCallRate'] ?? 0.0).toDouble(),
      videoCallRate: (json['videoCallRate'] ?? 0.0).toDouble(),
      messageRate: (json['messageRate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'offline',
      isAvailable: json['isAvailable'] ?? false,
      rating: json['rating'] != null
          ? Rating(
              averageScore: (json['rating']['averageScore'] ?? 0.0).toDouble(),
              totalRatings: json['rating']['totalRatings'] ?? 0,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'audioCallRate': audioCallRate,
      'videoCallRate': videoCallRate,
      'messageRate': messageRate,
      'status': status,
      'isAvailable': isAvailable,
      'rating': rating != null
          ? {
              'averageScore': rating!.averageScore,
              'totalRatings': rating!.totalRatings,
            }
          : null,
    };
  }
}
