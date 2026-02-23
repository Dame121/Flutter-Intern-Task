// lib/features/discovery/presentation/bloc/discovery_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';
import 'package:caller_host_app/features/discovery/domain/repositories/discovery_repository.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository repository;

  DiscoveryBloc({required this.repository})
      : super(const DiscoveryInitialState()) {
    on<FetchHostsEvent>(_onFetchHosts);
    on<FilterHostsEvent>(_onFilterHosts);
    on<RefreshHostsEvent>(_onRefreshHosts);
  }

  Future<void> _onFetchHosts(
    FetchHostsEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(const DiscoveryLoadingState());
    try {
      final hosts = await repository.getAvailableHosts(
        searchQuery: event.searchQuery,
        filterStatus: event.filterStatus,
      );

      if (hosts.isEmpty) {
        emit(const DiscoveryEmptyState());
      } else {
        emit(DiscoveryLoadedState(
          hosts: hosts,
          filterStatus: event.filterStatus,
        ));
      }
    } catch (e) {
      emit(DiscoveryErrorState(message: e.toString()));
    }
  }

  Future<void> _onFilterHosts(
    FilterHostsEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoadedState) {
      final currentState = state as DiscoveryLoadedState;
      emit(const DiscoveryLoadingState());

      try {
        final filteredHosts = await repository.getAvailableHosts(
          filterStatus: event.status,
        );

        if (filteredHosts.isEmpty) {
          emit(const DiscoveryEmptyState());
        } else {
          emit(DiscoveryLoadedState(
            hosts: filteredHosts,
            filterStatus: event.status,
          ));
        }
      } catch (e) {
        emit(DiscoveryErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onRefreshHosts(
    RefreshHostsEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoadedState) {
      final currentState = state as DiscoveryLoadedState;
      try {
        final hosts = await repository.getAvailableHosts(
          filterStatus: currentState.filterStatus,
        );

        if (hosts.isEmpty) {
          emit(const DiscoveryEmptyState());
        } else {
          emit(DiscoveryLoadedState(
            hosts: hosts,
            filterStatus: currentState.filterStatus,
          ));
        }
      } catch (e) {
        emit(DiscoveryErrorState(message: e.toString()));
      }
    }
  }
}
