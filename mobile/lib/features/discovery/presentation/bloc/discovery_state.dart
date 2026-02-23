// lib/features/discovery/presentation/bloc/discovery_state.dart

import 'package:equatable/equatable.dart';
import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitialState extends DiscoveryState {
  const DiscoveryInitialState();
}

class DiscoveryLoadingState extends DiscoveryState {
  const DiscoveryLoadingState();
}

class DiscoveryLoadedState extends DiscoveryState {
  final List<HostEntity> hosts;
  final String filterStatus;

  const DiscoveryLoadedState({
    required this.hosts,
    this.filterStatus = 'all',
  });

  @override
  List<Object?> get props => [hosts, filterStatus];
}

class DiscoveryErrorState extends DiscoveryState {
  final String message;

  const DiscoveryErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class DiscoveryEmptyState extends DiscoveryState {
  const DiscoveryEmptyState();
}
