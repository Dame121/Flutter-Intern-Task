// lib/features/discovery/data/repositories/discovery_repository_impl.dart

import 'package:caller_host_app/features/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';
import 'package:caller_host_app/features/discovery/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HostEntity>> getAvailableHosts({
    String? searchQuery,
    String? filterStatus,
  }) async {
    return await remoteDataSource.fetchAvailableHosts(
      searchQuery: searchQuery,
      filterStatus: filterStatus,
    );
  }

  @override
  Future<HostEntity> getHostById(String hostId) async {
    return await remoteDataSource.fetchHostById(hostId);
  }

  @override
  Future<List<HostEntity>> searchHosts(String query) async {
    return await remoteDataSource.fetchAvailableHosts(
      searchQuery: query,
    );
  }
}
