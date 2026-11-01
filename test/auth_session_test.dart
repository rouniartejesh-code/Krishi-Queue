import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/features/auth/data/auth_service.dart';
import 'package:krishi_queue/features/auth/domain/user_role.dart';

class _Token extends Fake implements IdTokenResult {
  _Token(this.claims);
  @override
  final Map<String, dynamic>? claims;
}

class _User extends Fake implements User {
  _User(this.claims, {this.error});
  final Map<String, dynamic>? claims;
  final Object? error;
  bool? forceRefreshRequested;

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    forceRefreshRequested = forceRefresh;
    if (error != null) throw error!;
    return _Token(claims);
  }
}

class _Auth extends Fake implements FirebaseAuth {
  _Auth(this._user);
  User? _user;
  int signOuts = 0;
  @override
  User? get currentUser => _user;
  @override
  Future<void> signOut() async {
    signOuts++;
    _user = null;
  }
}

void main() {
  test(
    'a restored session uses cached token claims without forced refresh',
    () async {
      final user = _User({'role': 'staff'});
      expect(await AuthService(_Auth(user)).currentRole(), UserRole.staff);
      expect(user.forceRefreshRequested, isFalse);
    },
  );

  test('no session does not create a farmer login', () async {
    expect(await AuthService(_Auth(null)).currentRole(), isNull);
  });

  test(
    'invalid role signs out and never returns an authorised portal',
    () async {
      final auth = _Auth(_User({'role': 'administrator'}));
      await expectLater(
        AuthService(auth).currentRole(),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'invalid-role',
          ),
        ),
      );
      expect(auth.currentUser, isNull);
      expect(auth.signOuts, 1);
    },
  );

  test(
    'network failure is not mistaken for a verified farmer session',
    () async {
      final auth = _Auth(
        _User(
          null,
          error: FirebaseAuthException(code: 'network-request-failed'),
        ),
      );
      await expectLater(
        AuthService(auth).currentRole(),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(auth.signOuts, 0);
    },
  );
}
