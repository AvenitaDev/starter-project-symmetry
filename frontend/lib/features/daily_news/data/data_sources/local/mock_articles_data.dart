import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

/// Set of mock articles for testing `daily_news`.
///
/// This file acts as a code-based local "data source"
/// to test the presentation/domain layer without depending
/// on the real API or database.
final List<ArticleModel> mockArticles = <ArticleModel>[
  const ArticleModel(
    id: 1,
    author: '',
    title: 'Test article 1',
    description: 'Description of test article 1.',
    url: 'https://example.com/mock-1',
    urlToImage: 'https://img.freepik.com/foto-gratis/al-atardecer-playa-tropical-mar-palmeras-coco_74190-1075.jpg?semt=ais_rp_progressive&w=740&q=80',
    publishedAt: '2026-03-04T10:00:00Z',
    content: 'Full content of test article 1.',
  ),
  const ArticleModel(
    id: 2,
    author: 'Mock Author 2',
    title: 'Test article 2',
    description: 'Description of test article 2.',
    url: 'https://example.com/mock-2',
    urlToImage: 'https://img.freepik.com/foto-gratis/al-atardecer-playa-tropical-mar-palmeras-coco_74190-1075.jpg?semt=ais_rp_progressive&w=740&q=80',
    publishedAt: '2026-03-04T11:00:00Z',
    content: 'Full content of test article 2.',
  ),
  const ArticleModel(
    id: 3,
    author: 'Mock Author 3',
    title: 'Test article 3',
    description: 'Description of test article 3.',
    url: 'https://example.com/mock-3',
    urlToImage: 'https://img.freepik.com/foto-gratis/al-atardecer-playa-tropical-mar-palmeras-coco_74190-1075.jpg?semt=ais_rp_progressive&w=740&q=80',
    publishedAt: '2026-03-04T12:00:00Z',
    content: 'Full content of test article 3.',
  ),
];

