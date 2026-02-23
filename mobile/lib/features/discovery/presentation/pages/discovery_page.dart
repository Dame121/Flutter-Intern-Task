// lib/features/discovery/presentation/pages/discovery_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/discovery/domain/entities/host_entity.dart';
import 'package:caller_host_app/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:caller_host_app/features/discovery/presentation/bloc/discovery_event.dart';
import 'package:caller_host_app/features/discovery/presentation/bloc/discovery_state.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const FetchHostsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Hosts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search hosts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<DiscoveryBloc>().add(
                        FetchHostsEvent(searchQuery: query),
                      );
                } else {
                  context.read<DiscoveryBloc>().add(const FetchHostsEvent());
                }
              },
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Available'),
                  selected: _selectedFilter == 'available',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'available' : null;
                    });
                    if (selected) {
                      context.read<DiscoveryBloc>().add(
                            const FilterHostsEvent(status: 'available'),
                          );
                    } else {
                      context.read<DiscoveryBloc>().add(
                            const FetchHostsEvent(),
                          );
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Busy'),
                  selected: _selectedFilter == 'busy',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'busy' : null;
                    });
                    if (selected) {
                      context.read<DiscoveryBloc>().add(
                            const FilterHostsEvent(status: 'busy'),
                          );
                    } else {
                      context.read<DiscoveryBloc>().add(
                            const FetchHostsEvent(),
                          );
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Offline'),
                  selected: _selectedFilter == 'offline',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'offline' : null;
                    });
                    if (selected) {
                      context.read<DiscoveryBloc>().add(
                            const FilterHostsEvent(status: 'offline'),
                          );
                    } else {
                      context.read<DiscoveryBloc>().add(
                            const FetchHostsEvent(),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hosts List
          Expanded(
            child: BlocBuilder<DiscoveryBloc, DiscoveryState>(
              builder: (context, state) {
                if (state is DiscoveryLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is DiscoveryLoadedState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DiscoveryBloc>().add(
                            const RefreshHostsEvent(),
                          );
                    },
                    child: ListView.builder(
                      itemCount: state.hosts.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final host = state.hosts[index];
                        return HostCard(host: host);
                      },
                    ),
                  );
                } else if (state is DiscoveryEmptyState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hosts found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                } else if (state is DiscoveryErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading hosts',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HostCard extends StatelessWidget {
  final HostEntity host;

  const HostCard({
    Key? key,
    required this.host,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to host detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${host.displayName}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundImage: host.profilePhotoUrl != null
                    ? NetworkImage(host.profilePhotoUrl!)
                    : null,
                child: host.profilePhotoUrl == null
                    ? Text(host.displayName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              // Host Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            host.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(host.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            host.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Bio
                    if (host.bio != null && host.bio!.isNotEmpty)
                      Text(
                        host.bio!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Rates and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rates',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Audio: \$${host.audioCallRate}/min • Video: \$${host.videoCallRate}/min',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (host.rating != null) ...[
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${host.rating!.averageScore}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                '${host.rating!.totalRatings} ratings',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'online':
        return Colors.green;
      case 'busy':
      case 'in-call':
        return Colors.orange;
      case 'offline':
      default:
        return Colors.grey;
    }
  }
}
