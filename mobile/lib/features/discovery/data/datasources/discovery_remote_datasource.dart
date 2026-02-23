// lib/features/discovery/data/datasources/discovery_remote_datasource.dart

import 'package:caller_host_app/core/services/api_client.dart';
import 'package:caller_host_app/features/discovery/data/models/host_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<HostModel>> fetchAvailableHosts({
    String? searchQuery,
    String? filterStatus,
  });

  Future<HostModel> fetchHostById(String hostId);
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final ApiClient apiClient;

  DiscoveryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<HostModel>> fetchAvailableHosts({
    String? searchQuery,
    String? filterStatus,
  }) async {
    try {
      String endpoint = '/api/discovery/hosts';
      
      // Build query parameters
      List<String> params = [];
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params.add('search=$searchQuery');
      }
      if (filterStatus != null && filterStatus.isNotEmpty) {
        params.add('status=$filterStatus');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.body is String
            ? (response.body as String).isNotEmpty
                ? response.body
                : '[]'
            : response.body;

        // Parse JSON response
        List<dynamic> jsonList =
            data is String ? [] : (data is List ? data : []);
        
        return jsonList
            .map((host) => HostModel.fromJson(host as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch hosts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hosts: $e');
    }
  }

  @override
  Future<HostModel> fetchHostById(String hostId) async {
    try {
      final response = await apiClient.get('/api/discovery/hosts/$hostId');

      if (response.statusCode == 200) {
        final data = response.body;
        return HostModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch host: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching host: $e');
    }
  }
}
