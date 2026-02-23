// lib/features/discovery/domain/repositories/discovery_repository.dart

import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';

abstract class DiscoveryRepository {
  Future<List<HostEntity>> getAvailableHosts({
    String? searchQuery,
    String? filterStatus,
  });

  Future<HostEntity> getHostById(String hostId);

  Future<List<HostEntity>> searchHosts(String query);
}
