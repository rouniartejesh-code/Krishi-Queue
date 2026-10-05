class NewsArticle {
  final String title;
  final String summary;
  final String source;
  final String category;
  final DateTime publishedAt;
  final String url;
  final String? imageUrl;

  const NewsArticle({
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.publishedAt,
    required this.url,
    this.imageUrl,
  });
}
