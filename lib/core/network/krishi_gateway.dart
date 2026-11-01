import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Only a public service URL belongs in an app build. Provider credentials are
/// kept in the Firebase function's secret store.
class KrishiGateway {
  KrishiGateway({
    http.Client? client,
    String? baseUrl,
    Future<String?> Function()? token,
  }) : _client = client ?? http.Client(),
       _baseUrl =
           baseUrl ?? const String.fromEnvironment('KRISHI_API_BASE_URL'),
       _token = token ?? _firebaseToken;

  final http.Client _client;
  final String _baseUrl;
  final Future<String?> Function() _token;

  bool get configured {
    final uri = Uri.tryParse(_baseUrl);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  static Future<String?> _firebaseToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> post(
    String route,
    Map<String, dynamic> body,
  ) async {
    if (!configured) {
      throw const GatewayException(
        'Online help is not connected yet. Saved help still works.',
      );
    }
    String? token;
    try {
      token = await _token().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Some injected/providers return Future<String> at runtime. Catching the
      // timeout avoids a nullable onTimeout callback violating that subtype.
      token = null;
    }
    if (token == null) {
      throw const GatewayException(
        'Sign in to use this online service. Offline help is always available.',
      );
    }
    try {
      final uri = Uri.parse(
        '${_baseUrl.replaceAll(RegExp(r'/+$'), '')}/$route',
      );
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        throw const GatewayException(
          'Please sign in again to use online help.',
        );
      }
      if (response.statusCode == 429) {
        throw const GatewayException(
          'Online help is busy. Please try again later.',
        );
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.bodyBytes.length > 300000) {
        throw const GatewayException(
          'Online information is unavailable. Please try again later.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) throw const FormatException();
      return data;
    } on GatewayException {
      rethrow;
    } catch (_) {
      throw const GatewayException(
        'Connection is slow or unavailable. Your saved information is still available.',
      );
    }
  }

  void dispose() => _client.close();
}

class GatewayException implements Exception {
  final String message;
  const GatewayException(this.message);
  @override
  String toString() => message;
}
