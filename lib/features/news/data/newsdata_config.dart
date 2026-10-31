class NewsDataConfig {
  const NewsDataConfig._();

  static const apiKey = String.fromEnvironment('NEWSDATA_API_KEY');

  static const endpoint = 'https://newsdata.io/api/1/latest';
}
