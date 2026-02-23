// lib/features/discovery/presentation/bloc/discovery_event.dart

import 'package:equatable/equatable.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class FetchHostsEvent extends DiscoveryEvent {
  final String? searchQuery;
  final String? sortBy;

  const FetchHostsEvent({
    this.searchQuery,
    this.sortBy,
  });

  @override
  List<Object?> get props => [searchQuery, sortBy];
}

class FilterHostsEvent extends DiscoveryEvent {
  final String status; // all, available, busy, offline

  const FilterHostsEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

class RefreshHostsEvent extends DiscoveryEvent {
  const RefreshHostsEvent();
}
