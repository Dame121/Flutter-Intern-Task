// lib/features/call/domain/entities/call_entity.dart

import 'package:equatable/equatable.dart';

class CallSessionEntity extends Equatable {
  final String sessionId;
  final String callerId;
  final String hostId;
  final String callType; // audio or video
  final String state; // initiated, ringing, active, ended
  final DateTime startedAt;
  final DateTime? connectedAt;
  final DateTime? endedAt;
  final int duration; // in seconds
  final double totalCost;

  const CallSessionEntity({
    required this.sessionId,
    required this.callerId,
    required this.hostId,
    required this.callType,
    required this.state,
    required this.startedAt,
    this.connectedAt,
    this.endedAt,
    this.duration = 0,
    this.totalCost = 0.0,
  });

  @override
  List<Object?> get props => [
    sessionId,
    callerId,
    hostId,
    callType,
    state,
    startedAt,
    connectedAt,
    endedAt,
    duration,
    totalCost,
  ];
}

class RtcTokenEntity extends Equatable {
  final String token;
  final String channel;
  final String agoraAppId;
  final int uid;

  const RtcTokenEntity({
    required this.token,
    required this.channel,
    required this.agoraAppId,
    required this.uid,
  });

  @override
  List<Object?> get props => [token, channel, agoraAppId, uid];
}
