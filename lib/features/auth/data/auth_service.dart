import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_validation.dart';
import '../domain/user_role.dart';

class AuthService {
  AuthService(this.auth);

  final FirebaseAuth auth;
  static Future<void>? _googleInitialization;

  static AuthService? tryCreate() {
    try {
      return AuthService(FirebaseAuth.instance);
    } catch (_) {
      return null;
    }
  }

  static bool get supportsPhone =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get supportsGoogle =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Firebase persists the user. Avoid a forced network refresh on app launch.
  Future<UserRole?> currentRole({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user == null) return null;
    final token = await user
        .getIdTokenResult(forceRefresh)
        .timeout(const Duration(seconds: 15));
    final role = roleFromClaims(token.claims);
    if (role == null) {
      await auth.signOut();
      throw FirebaseAuthException(code: 'invalid-role');
    }
    return role;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!supportsGoogle) {
      throw FirebaseAuthException(code: 'unsupported-platform');
    }
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      return auth.signInWithPopup(provider);
    }

    final google = GoogleSignIn.instance;
    // These optional OAuth client IDs are public configuration, never secrets.
    const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    try {
      await (_googleInitialization ??= google.initialize(
        clientId: clientId.isEmpty ? null : clientId,
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      ));
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    return auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<void> signOut() async {
    await auth.signOut().timeout(const Duration(seconds: 15));
    if (!kIsWeb && _googleInitialization != null) {
      try {
        await GoogleSignIn.instance.signOut().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {
        // Firebase sign-out is authoritative if Google is unavailable.
      }
    }
  }
}
