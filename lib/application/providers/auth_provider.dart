import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../di/injection_container.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final authRepo = ref.read(authRepositoryProvider);
    final isAuthenticated = await authRepo.isAuthenticated();

    if (isAuthenticated) {
      final userResult = await authRepo.getCurrentUser();
      userResult.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        },
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login() async {
    state = state.copyWith(status: AuthStatus.loading);

    // Small delay to ensure UI updates before starting auth flow
    await Future.delayed(const Duration(milliseconds: 100));

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.authenticate();

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (token) async {
        // Get user profile after successful authentication
        final userResult = await authRepo.getCurrentUser();
        userResult.fold(
          (failure) {
            state = state.copyWith(
              status: AuthStatus.error,
              errorMessage: failure.message,
            );
          },
          (user) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            );
          },
        );
      },
    );
  }

  /// Cancel the current authentication flow
  Future<void> cancelLogin() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.cancelAuthentication();

    // Reset state to unauthenticated
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.logout();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
