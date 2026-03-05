import 'package:intl/intl.dart';

/// Decodes [publishedAt] (e.g. "2026-03-04T23:28:07Z") and returns a readable English string in local time.
String formatPublishedAt(String? publishedAt) {
  if (publishedAt == null || publishedAt.isEmpty) return '';
  try {
    final date = DateTime.parse(publishedAt).toLocal();
    return DateFormat.yMMMd('en').add_jm().format(date);
  } catch (_) {
    return publishedAt;
  }
}
