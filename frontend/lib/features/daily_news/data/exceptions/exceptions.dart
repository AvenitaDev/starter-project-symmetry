class NewsApiException implements Exception {
  final String message;
  NewsApiException(this.message);
}