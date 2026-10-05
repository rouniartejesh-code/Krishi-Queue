import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/news_article.dart';
import 'newsdata_config.dart';

class FarmerNewsApi {
  final http.Client _client;

  FarmerNewsApi({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<NewsArticle>> fetchLatest() async {
    final uri = Uri.parse(
      NewsDataConfig.endpoint,
    ).replace(
      queryParameters: {
        'apikey': NewsDataConfig.apiKey.trim(),
        'q':
            'agriculture OR farmer OR farmers OR kisan OR farming OR crop OR crops OR MSP OR procurement OR mandi',
        'country': 'in',
        'language': 'en',
        'size': '10',
      },
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'KrishiQueue/1.0',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final body = response.body;

      Map<String, dynamic> data;

      try {
        final decoded = jsonDecode(body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception(
            'NewsData returned invalid JSON.',
          );
        }

        data = decoded;
      } catch (error) {
        throw Exception(
          'NewsData returned invalid JSON: $error',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          _extractApiError(
            data,
            response.statusCode,
          ),
        );
      }

      final status = data['status'];

      if (status != 'success') {
        throw Exception(
          _extractApiError(
            data,
            response.statusCode,
          ),
        );
      }

      final rawResults = data['results'];

      if (rawResults is! List) {
        return [];
      }

      final articles = <NewsArticle>[];

      for (final rawArticle in rawResults) {
        if (rawArticle is! Map<String, dynamic>) {
          continue;
        }

        final title = _string(
          rawArticle['title'],
        );

        final link = _string(
          rawArticle['link'],
        );

        if (title.isEmpty || link.isEmpty) {
          continue;
        }

        final description = _string(
          rawArticle['description'],
        );

        final content = _string(
          rawArticle['content'],
        );

        final source = _string(
          rawArticle['source_name'],
        );

        final imageUrl = _string(
          rawArticle['image_url'],
        );

        final pubDate = _string(
          rawArticle['pubDate'],
        );

        final article = NewsArticle(
          title: _clean(title),
          summary: _createSummary(
            description,
            content,
            title,
          ),
          source: source.isEmpty
              ? 'NewsData.io'
              : _clean(source),
          category: _category(
            title,
            description,
          ),
          publishedAt: _parseDate(pubDate),
          url: link,
          imageUrl: imageUrl.isEmpty
              ? null
              : imageUrl,
        );

        if (_isFarmerNews(article)) {
          articles.add(article);
        }
      }

      final unique = <String, NewsArticle>{};

      for (final article in articles) {
        final key = _normalise(
          article.title,
        );

        if (key.isEmpty) {
          continue;
        }

        final existing = unique[key];

        if (existing == null) {
          unique[key] = article;
        } else {
          unique[key] = _prefer(
            existing,
            article,
          );
        }
      }

      final result = unique.values.toList()
        ..sort(
          (a, b) => b.publishedAt.compareTo(
            a.publishedAt,
          ),
        );

      return result;
    } catch (error) {
      throw Exception(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  String _extractApiError(
    Map<String, dynamic> data,
    int statusCode,
  ) {
    final topMessage = data['message'];

    if (topMessage is String &&
        topMessage.trim().isNotEmpty) {
      return 'NewsData error ($statusCode): ${topMessage.trim()}';
    }

    final results = data['results'];

    if (results is Map<String, dynamic>) {
      final resultMessage = results['message'];

      if (resultMessage is String &&
          resultMessage.trim().isNotEmpty) {
        return 'NewsData error ($statusCode): ${resultMessage.trim()}';
      }
    }

    return 'NewsData error ($statusCode).';
  }

  bool _isFarmerNews(
    NewsArticle article,
  ) {
    final text =
        '${article.title} ${article.summary}'
            .toLowerCase();

    const keywords = <String>[
      'farmer',
      'farmers',
      'kisan',
      'agriculture',
      'agricultural',
      'farming',
      'farm',
      'crop',
      'crops',
      'cultivation',
      'harvest',
      'msp',
      'procurement',
      'mandi',
      'paddy',
      'wheat',
      'rice',
      'maize',
      'cotton',
      'soybean',
      'sugarcane',
      'fertilizer',
      'fertiliser',
      'irrigation',
      'seed',
      'seeds',
      'livestock',
      'dairy',
      'pm-kisan',
      'pm kisan',
      'crop insurance',
      'kharif',
      'rabi',
      'horticulture',
      'agritech',
      'agri tech',
      'farm equipment',
      'farm machinery',
      'agricultural technology',
      'farm income',
      'farm produce',
      'farm prices',
      'agriculture ministry',
    ];

    return keywords.any(
      text.contains,
    );
  }

  String _category(
    String title,
    String description,
  ) {
    final text =
        '$title $description'.toLowerCase();

    if (text.contains('msp') ||
        text.contains('procurement') ||
        text.contains('mandi')) {
      return 'MSP & Procurement';
    }

    if (text.contains('pm-kisan') ||
        text.contains('pm kisan') ||
        text.contains('scheme') ||
        text.contains('subsidy')) {
      return 'Government Schemes';
    }

    if (text.contains('weather') ||
        text.contains('monsoon') ||
        text.contains('rainfall')) {
      return 'Weather & Crops';
    }

    if (text.contains('livestock') ||
        text.contains('dairy')) {
      return 'Livestock & Dairy';
    }

    if (text.contains('technology') ||
        text.contains('agritech') ||
        text.contains('tractor') ||
        text.contains('machinery')) {
      return 'Agri Technology';
    }

    if (text.contains('fertilizer') ||
        text.contains('fertiliser') ||
        text.contains('seed') ||
        text.contains('irrigation')) {
      return 'Farm Inputs';
    }

    if (text.contains('market') ||
        text.contains('price') ||
        text.contains('prices')) {
      return 'Markets & Crops';
    }

    return 'Agriculture';
  }

  NewsArticle _prefer(
    NewsArticle current,
    NewsArticle next,
  ) {
    if (current.imageUrl == null &&
        next.imageUrl != null) {
      return next;
    }

    if (next.publishedAt.isAfter(
      current.publishedAt,
    )) {
      return next;
    }

    return current;
  }

  DateTime _parseDate(
    String value,
  ) {
    if (value.isEmpty) {
      return DateTime.now();
    }

    final parsed = DateTime.tryParse(
      value,
    );

    return parsed?.toLocal() ??
        DateTime.now();
  }

  String _createSummary(
    String description,
    String content,
    String title,
  ) {
    var summary = description.trim();

    if (summary.isEmpty) {
      summary = content.trim();
    }

    summary = _clean(summary);

    if (summary.isEmpty ||
        summary.toLowerCase() ==
            title.toLowerCase()) {
      return 'Tap to read the full farmer and agriculture news update.';
    }

    if (summary.length <= 180) {
      return summary;
    }

    return '${summary.substring(0, 177).trimRight()}...';
  }

  String _string(
    dynamic value,
  ) {
    if (value is String) {
      return value.trim();
    }

    return '';
  }

  String _clean(
    String value,
  ) {
    var text = value;

    const replacements = <String, String>{
      '&amp;': '&',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&lt;': '<',
      '&gt;': '>',
      '&#8217;': '’',
      '&#8220;': '“',
      '&#8221;': '”',
      '&#160;': ' ',
    };

    for (final entry in replacements.entries) {
      text = text.replaceAll(
        entry.key,
        entry.value,
      );
    }

    return text
        .replaceAll(
          RegExp(r'<[^>]*>'),
          ' ',
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  String _normalise(
    String value,
  ) {
    return value
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9]+'),
          ' ',
        )
        .trim();
  }

  void dispose() {
    _client.close();
  }
}