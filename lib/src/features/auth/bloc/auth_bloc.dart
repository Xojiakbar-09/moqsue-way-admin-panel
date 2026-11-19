import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

sealed class AuthAction extends AuthEvent {
  const AuthAction();
}

final class SignInRequested extends AuthAction {
  const SignInRequested(this.email, this.password);

  final String email;
  final String password;
}

final class SignOutRequested extends AuthAction {
  const SignOutRequested();
}

final class _SessionChanged extends AuthEvent {
  const _SessionChanged(this.user);

  final User? user;
}

final class _SessionFailed extends AuthEvent {
  const _SessionFailed();
}

final class AuthState {
  const AuthState({
    this.user,
    this.checkingSession = false,
    this.busy = false,
    this.error,
  });

  final User? user;
  final bool checkingSession;
  final bool busy;
  final String? error;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._auth) : super(const AuthState(checkingSession: true)) {
    on<_SessionChanged>((event, emit) {
      emit(AuthState(user: event.user, busy: state.busy));
    });
    on<_SessionFailed>((event, emit) {
      emit(AuthState(
        user: state.user,
        busy: state.busy,
        error: 'Sessiyani tekshirib bo‘lmadi. Sahifani yangilang.',
      ));
    });
    on<AuthAction>(_onAction);

    _session = _auth.authStateChanges().listen(
      (user) => add(_SessionChanged(user)),
      onError: (Object error, StackTrace stackTrace) {
        add(const _SessionFailed());
      },
    );
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _session;

  Future<void> _onAction(AuthAction event, Emitter<AuthState> emit) async {
    if (state.busy || state.checkingSession) return;
    emit(AuthState(user: state.user, busy: true));

    try {
      switch (event) {
        case SignInRequested(:final email, :final password):
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        case SignOutRequested():
          await _auth.signOut();
      }
      emit(AuthState(user: _auth.currentUser));
    } on FirebaseAuthException catch (error) {
      emit(AuthState(user: state.user, error: _message(error.code)));
    } catch (_) {
      emit(AuthState(
        user: state.user,
        error: 'Amalni bajarib bo‘lmadi. Qayta urinib ko‘ring.',
      ));
    }
  }

  String _message(String code) => switch (code) {
    'invalid-credential' || 'wrong-password' || 'user-not-found' =>
      'Email yoki parol noto‘g‘ri.',
    'invalid-email' => 'Email manzilini tekshiring.',
    'user-disabled' => 'Bu akkaunt o‘chirilgan.',
    'too-many-requests' => 'Juda ko‘p urinish. Birozdan keyin qayta urining.',
    'network-request-failed' => 'Internetga ulanishni tekshiring.',
    'operation-not-allowed' => 'Firebase’da Email/Password orqali kirish o‘chiq.',
    _ => 'Amalni bajarib bo‘lmadi. Qayta urinib ko‘ring.',
  };

  @override
  Future<void> close() async {
    await _session.cancel();
    await super.close();
  }
}
