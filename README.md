# Flutter Peer-to-Peer Calling Platform 🚀

A two-sided platform where Callers can discover Hosts, make audio/video calls, send messages, and be billed per-minute, while Hosts earn money from their time.

## Phase 1: Foundation to Working MVP

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile Client                     │
│  (iOS & Android - Clean Architecture with Bloc)             │
└────────────┬────────────────────────────────────────────────┘
             │
             │ HTTPS + WebSocket
             ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway (Kong)                      │
│  ├─ JWT Validation                                           │
│  ├─ Rate Limiting                                            │
│  └─ Request Routing                                          │
└────────────┬────────────────────────────────────────────────┘
             │
    ┌────────┼────────┬────────┬────────┬────────┐
    ▼        ▼        ▼        ▼        ▼        ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌──────────┐
│ Auth   ││ User   ││Discovery││ Chat   ││ Call   ││ Billing  │
│Service ││Service ││Service  ││Service ││Service ││ Service  │
│        ││        ││         ││        ││        ││          │
│Postgre ││MongoDB ││MongoDB +││MongoDB ││ Redis  ││PostgreSQL│
│SQL     ││        ││ Redis   ││        ││        ││          │
└────────┘└────────┘└────────┘└────────┘└────────┘└──────────┘
    │        │        │        │        │        │
    └────────┴────────┴────────┴────────┴────────┘
             │
    ┌────────▼────────────┐
    │  Apache Kafka       │
    │  Event Bus          │
    └────────┬────────────┘
             │
             ▼
┌──────────────────────────┐
│ Notification Service     │
│ Firebase Cloud Messaging │
└──────────────────────────┘
```

## Project Structure

```
flutter-intern-task/
├── mobile/
│   ├── lib/
│   │   ├── core/                    # Shared utilities, constants
│   │   │   ├── config/
│   │   │   ├── constants/
│   │   │   ├── extensions/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   │
│   │   ├── features/                # Feature modules (Bloc-based)
│   │   │   ├── auth/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   ├── discovery/
│   │   │   ├── chat/
│   │   │   ├── call/
│   │   │   ├── billing/
│   │   │   └── notifications/
│   │   │
│   │   └── main.dart
│   │
│   ├── pubspec.yaml
│   ├── android/
│   ├── ios/
│   └── test/
│
├── backend/
│   ├── api-gateway/
│   ├── auth-service/
│   ├── user-service/
│   ├── discovery-service/
│   ├── chat-service/
│   ├── call-service/
│   ├── billing-service/
│   └── notification-service/
│
├── infrastructure/
│   ├── docker-compose.yml
│   ├── kubernetes/
│   └── monitoring/
│
└── README.md

```

## Core Requirements - Phase 1

### ✅ Architecture Foundation
- [x] Project structure initialized
- [ ] Clean Architecture implementation
- [ ] Bloc state management
- [ ] Repository pattern setup
- [ ] Feature-first folder structure

### ✅ Authentication & Two-Sided Roles
- [ ] Registration with role selection (Caller/Host)
- [ ] Secure login with JWT
- [ ] Persistent session storage
- [ ] Multi-device support
- [ ] Host profile setup with rates
- [ ] Caller profile setup

### ✅ Host Discovery (Caller-Side)
- [ ] Browsable Host list
- [ ] Host cards with rates display
- [ ] Availability status
- [ ] Full profile pages
- [ ] Credit balance visibility

### ✅ Credit System
- [ ] Credit package purchase
- [ ] Server-side balance enforcement
- [ ] Insufficient balance blocking
- [ ] Top-up prompts

### ✅ Real-Time Messaging
- [ ] Text messaging with real-time delivery
- [ ] Message delivery states (Sent, Delivered, Read)
- [ ] Per-message billing
- [ ] Server-side timestamp validation
- [ ] Idempotent submission

### ✅ Audio & Video Calling
- [ ] Audio call initiation and handling
- [ ] Video call with preview
- [ ] Live cost ticker during calls
- [ ] Mute, speaker, camera controls
- [ ] Network drop auto-reconnect
- [ ] Crash recovery
- [ ] Audio-to-video upgrade mid-call

### ✅ Billing Engine
- [ ] Credit pre-authorization
- [ ] Server-side per-minute deduction
- [ ] Auto-end on zero balance
- [ ] Platform revenue tracking
- [ ] Host earnings ledger

### ✅ Push Notifications
- [ ] Multi-device support
- [ ] Incoming call notifications
- [ ] Message notifications
- [ ] Permission handling

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter (latest stable)
- **Language**: Dart
- **State Management**: Bloc
- **Architecture**: Clean Architecture
- **Real-time**: Socket.io
- **Media**: Agora SDK
- **Notifications**: Firebase Cloud Messaging
- **Storage**: flutter_secure_storage

### Backend (Microservices)
- **Runtime**: Node.js + Express
- **API Gateway**: Kong
- **Inter-service**: Apache Kafka
- **Databases**:
  - PostgreSQL: Auth, Billing
  - MongoDB: User, Chat, Discovery, Notifications
  - Redis: Call Service sessions, Socket.io adapter
- **Media**: Agora
- **Container**: Docker
- **Orchestration**: Docker Compose (local), Kubernetes (production)

## Getting Started

### Prerequisites
- Flutter SDK (latest)
- Node.js & npm
- Docker & Docker Compose
- PostgreSQL, MongoDB, Redis (via Docker)
- Agora account (free tier)
- Firebase project

### Local Setup

```bash
# Start all backend services
docker-compose -f infrastructure/docker-compose.yml up -d

# Setup Flutter app
cd mobile
flutter pub get

# Run app
flutter run
```

## Implementation Progress

| Phase | Status | Deadline |
|-------|--------|----------|
| Phase 1: Foundation & MVP | 🔄 In Progress | 72 hours |
| Phase 2: Advanced Features | ⏳ Planned | - |
| Phase 3: Production Scale | ⏳ Planned | - |

## Key Decisions

### State Management: Bloc
**Reasoning**: 
- Clean separation of business logic from UI
- Built-in testability
- Unidirectional data flow makes debugging predictable
- Excellent for complex two-sided business logic

### Database Strategy
- **PostgreSQL for Auth/Billing**: ACID compliance required for financial transactions
- **MongoDB for User/Chat/Discovery**: High write volume, flexible schema
- **Redis for Call Sessions**: Sub-millisecond reads, TTL-based expiry

### Kafka for Events
- Decouples services
- Allows call-ended → billing reconciliation without direct HTTP calls
- Enables audit trail and replay

### Agora SDK
- Handles TURN/STUN servers globally
- No need to manage media infrastructure
- Scalable to thousands of concurrent calls

## Security & Compliance

- ✅ No hardcoded credentials
- ✅ Short-lived RTC tokens (server-side generation)
- ✅ HTTPS only for API calls
- ✅ JWT with refresh token rotation
- ✅ Row-level locking for financial transactions
- ✅ Server-side timestamp validation
- ✅ Idempotent API endpoints

## Revenue Protection

- ✅ Credit pre-authorization before call
- ✅ Server-side billing timer (not client-side)
- ✅ Session locking to prevent duplicate charges
- ✅ Graceful timeout handling
- ✅ Network reconnect doesn't create duplicate sessions

## Git Commit Strategy

Each feature implementation includes:
- Feature branch for feature: `feature/auth-login`
- Commits organized by concern (Data layer → Domain → Presentation)
- Meaningful commit messages following conventional commits

---

**Version**: 0.1.0  
**Last Updated**: February 2026  
**Target Completion**: 72 hours from start
