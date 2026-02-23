// backend/discovery-service/src/index.js
require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());

// Mock database of hosts
const mockHosts = [
  {
    id: 'host-001',
    displayName: 'John Doe',
    profilePhotoUrl: null,
    bio: 'Expert mentor with 10+ years experience',
    audioCallRate: 0.5,
    videoCallRate: 1.0,
    messageRate: 0.1,
    status: 'available',
    isAvailable: true,
    rating: {
      averageScore: 4.8,
      totalRatings: 142,
    },
  },
  {
    id: 'host-002',
    displayName: 'Sarah Smith',
    profilePhotoUrl: null,
    bio: 'Business consultant specializing in startups',
    audioCallRate: 0.75,
    videoCallRate: 1.5,
    messageRate: 0.15,
    status: 'available',
    isAvailable: true,
    rating: {
      averageScore: 4.9,
      totalRatings: 89,
    },
  },
  {
    id: 'host-003',
    displayName: 'Mike Johnson',
    profilePhotoUrl: null,
    bio: 'Software engineer and tech coach',
    audioCallRate: 1.0,
    videoCallRate: 2.0,
    messageRate: 0.2,
    status: 'busy',
    isAvailable: false,
    rating: {
      averageScore: 4.7,
      totalRatings: 156,
    },
  },
  {
    id: 'host-004',
    displayName: 'Emily Davis',
    profilePhotoUrl: null,
    bio: 'Career coach and HR specialist',
    audioCallRate: 0.6,
    videoCallRate: 1.2,
    messageRate: 0.12,
    status: 'available',
    isAvailable: true,
    rating: {
      averageScore: 4.6,
      totalRatings: 201,
    },
  },
  {
    id: 'host-005',
    displayName: 'David Wilson',
    profilePhotoUrl: null,
    bio: 'Marketing strategist and growth hacker',
    audioCallRate: 0.8,
    videoCallRate: 1.6,
    messageRate: 0.18,
    status: 'offline',
    isAvailable: false,
    rating: {
      averageScore: 4.5,
      totalRatings: 67,
    },
  },
];

app.get('/health', (req, res) => res.json({ status: 'Discovery Service OK' }));

// Get all hosts with optional filtering
app.get('/api/discovery/hosts', (req, res) => {
  try {
    const { search, status } = req.query;

    let filtered = [...mockHosts];

    // Filter by search query
    if (search && search.trim()) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(
        (host) =>
          host.displayName.toLowerCase().includes(searchLower) ||
          host.bio.toLowerCase().includes(searchLower)
      );
    }

    // Filter by status
    if (status && status.trim()) {
      filtered = filtered.filter(
        (host) => host.status.toLowerCase() === status.toLowerCase()
      );
    }

    res.json(filtered);
  } catch (error) {
    console.error('Error fetching hosts:', error);
    res.status(500).json({ error: 'Failed to fetch hosts' });
  }
});

// Get specific host by ID
app.get('/api/discovery/hosts/:hostId', (req, res) => {
  try {
    const { hostId } = req.params;
    const host = mockHosts.find((h) => h.id === hostId);

    if (!host) {
      return res.status(404).json({ error: 'Host not found' });
    }

    res.json(host);
  } catch (error) {
    console.error('Error fetching host:', error);
    res.status(500).json({ error: 'Failed to fetch host' });
  }
});

app.listen(3002, () => console.log('Discovery Service on 3002'));
