// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:caller_host_app/core/services/api_client.dart';
import 'package:caller_host_app/core/services/secure_storage_service.dart';
import 'package:caller_host_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:caller_host_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:caller_host_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:caller_host_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:caller_host_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:caller_host_app/features/auth/presentation/bloc/auth_state.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize secure storage
  final secureStorage = SecureStorageService();
  await secureStorage.init();
  getIt.registerSingleton<SecureStorageService>(secureStorage);
  
  // Register API Client
  getIt.registerSingleton<ApiClient>(
    ApiClient(http.Client(), secureStorage),
  );
  
  // Register Data Sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  
  // Register Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: secureStorage,
    ),
  );
  
  // Register Blocs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      authRepository: getIt<AuthRepository>(),
      secureStorage: secureStorage,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caller Host App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (context) => getIt<AuthBloc>()
          ..add(const CheckAuthStatusEvent()),
        child: const AppHome(),
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthCheckingState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (state is AuthSuccessState) {
            return _buildHomeScreen(context, state);
          }
          
          if (state is AuthLoggedOutState ||
              state is AuthUnauthenticatedState ||
              state is AuthFailureState) {
            return const LoginScreen();
          }
          
          return const LoginScreen();
        },
      ),
    );
  }
  
  Widget _buildHomeScreen(BuildContext context, AuthSuccessState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${state.user.displayName}!'),
            Text('Role: ${state.user.role}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutEvent());
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  String _selectedRole = 'caller';
  final _displayNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            if (_isRegister)
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
            if (_isRegister) const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isRegister)
              Column(
                children: [
                  const Text('Select Role:'),
                  DropdownButton<String>(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'caller', child: Text('Caller')),
                      DropdownMenuItem(value: 'host', child: Text('Host')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRole = value ?? 'caller');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ElevatedButton(
              onPressed: _handleAuthAction,
              child: Text(_isRegister ? 'Register' : 'Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _isRegister = !_isRegister),
              child: Text(_isRegister
                  ? 'Already have account? Login'
                  : 'Don\'t have account? Register'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleAuthAction() {
    if (_isRegister) {
      context.read<AuthBloc>().add(RegisterEvent(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
        role: _selectedRole,
      ));
    } else {
      context.read<AuthBloc>().add(LoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}
