// lib/features/discovery/domain/entities/host_entity.dart

import 'package:equatable/equatable.dart';

class HostEntity extends Equatable {
  final String id;
  final String displayName;
  final String? profilePhotoUrl;
  final String? bio;
  final double audioCallRate;
  final double videoCallRate;
  final double messageRate;
  final String status; // online, busy, offline, in-call
  final bool isAvailable;
  final Rating? rating;

  const HostEntity({
    required this.id,
    required this.displayName,
    this.profilePhotoUrl,
    this.bio,
    required this.audioCallRate,
    required this.videoCallRate,
    required this.messageRate,
    required this.status,
    required this.isAvailable,
    this.rating,
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    profilePhotoUrl,
    bio,
    audioCallRate,
    videoCallRate,
    messageRate,
    status,
    isAvailable,
    rating,
  ];
}

class Rating extends Equatable {
  final double average;
  final int count;

  const Rating({
    required this.average,
    required this.count,
  });

  @override
  List<Object?> get props => [average, count];
}
