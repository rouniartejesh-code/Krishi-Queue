import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class MarketPrice {
  final String commodity;
  final String variety;
  final String market;
  final String district;
  final String state;
  final String grade;
  final int minPrice;
  final int maxPrice;
  final int modalPrice;
  final DateTime observationDate;

  const MarketPrice({
    required this.commodity,
    required this.variety,
    required this.market,
    required this.district,
    required this.state,
    required this.grade,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.observationDate,
  });
}

abstract class MarketPriceRepository {
  Future<List<MarketPrice>> getMarketPrices();
}

class MarketPriceRepositoryImpl implements MarketPriceRepository {
  const MarketPriceRepositoryImpl();

  static const String _resourceId =
      '9ef84268-d588-465a-a308-a864a43d0070';

  // Move this key to a backend before production deployment.
  static const String _apiKey =
      '579b464db66ec23bdd000001b099fdb1197345055e3f5b428f067544';

  static const String _endpoint =
      'https://api.data.gov.in/resource/$_resourceId';

  static const int _pageSize = 100;
  static const int _maxAttempts = 3;

  @override
  Future<List<MarketPrice>> getMarketPrices() async {
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        return await _fetchPage();
      } catch (error) {
        lastError = error;

        if (attempt == _maxAttempts || !_isRetryable(error)) {
          break;
        }

        await Future<void>.delayed(
          Duration(seconds: attempt),
        );
      }
    }

    throw lastError ??
        Exception('Government market-price API request failed.');
  }

  Future<List<MarketPrice>> _fetchPage() async {
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: const {
        'api-key': _apiKey,
        'format': 'json',
        'limit': '$_pageSize',
        'offset': '0',
      },
    );

    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _MarketApiException(
        response.statusCode,
        _statusMessage(response.statusCode),
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid government market-price response.');
    }

    final records = decoded['records'];

    if (records is! List) {
      throw Exception('Government market-price API returned no records.');
    }

    final prices = <MarketPrice>[];

    for (final record in records) {
      if (record is! Map) {
        continue;
      }

      final price = _parseRecord(record);

      if (price != null) {
        prices.add(price);
      }
    }

    if (prices.isEmpty) {
      throw Exception(
        'Government market-price API returned no usable records.',
      );
    }

    return prices;
  }

  bool _isRetryable(Object error) {
    if (error is _MarketApiException) {
      return error.statusCode == 429 ||
          error.statusCode == 500 ||
          error.statusCode == 502 ||
          error.statusCode == 503 ||
          error.statusCode == 504;
    }

    return error is TimeoutException;
  }

  String _statusMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Government API authentication failed. Check the data.gov.in API key.';
      case 403:
        return 'Government API access was denied for this API key.';
      case 404:
        return 'Government mandi-price resource was not found.';
      case 429:
        return 'Government API rate limit reached. Please retry shortly.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Government market-price service is temporarily unavailable (HTTP $statusCode).';
      default:
        return 'Government market-price API returned HTTP $statusCode.';
    }
  }

  MarketPrice? _parseRecord(Map record) {
    final commodity = _stringValue(record['commodity']);
    final arrivalDate = _parseDate(record['arrival_date']);
    final minPrice = _intValue(record['min_price']);
    final maxPrice = _intValue(record['max_price']);
    final modalPrice = _intValue(record['modal_price']);

    if (commodity.isEmpty ||
        arrivalDate == null ||
        minPrice == null ||
        maxPrice == null ||
        modalPrice == null) {
      return null;
    }

    return MarketPrice(
      commodity: commodity,
      variety: _stringValue(record['variety'], fallback: 'Not specified'),
      market: _stringValue(record['market'], fallback: 'Not specified'),
      district: _stringValue(record['district'], fallback: 'Not specified'),
      state: _stringValue(record['state'], fallback: 'Not specified'),
      grade: _stringValue(record['grade'], fallback: 'Not specified'),
      minPrice: minPrice,
      maxPrice: maxPrice,
      modalPrice: modalPrice,
      observationDate: arrivalDate,
    );
  }

  String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return double.tryParse(text.replaceAll(',', ''))?.round();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(text);

    if (direct != null) {
      return direct;
    }

    final parts = text.split('/');

    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}

class _MarketApiException implements Exception {
  final int statusCode;
  final String message;

  const _MarketApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}
