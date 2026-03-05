import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/data_sources/remote/firebase_service.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/models/article_draft.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../data_sources/local/mock_articles_data.dart';

/// Implementation of `ArticleRepository` that combines mock articles
/// with articles uploaded to Firebase.
class ArticleRepositoryMockImpl implements ArticleRepository {
  final List<ArticleEntity> _savedArticles;
  final FirebaseArticleService _firebaseArticleService;

  ArticleRepositoryMockImpl({
    List<ArticleEntity>? initialSavedArticles,
    required FirebaseArticleService firebaseArticleService,
  })  : _savedArticles =
            initialSavedArticles ?? List<ArticleEntity>.from(mockArticles),
        _firebaseArticleService = firebaseArticleService;

  @override
  Future<Either<Failure, List<ArticleEntity>>> getNewsArticles() async {
    try {
      final mockList = List<ArticleEntity>.from(mockArticles);
      final firebaseList = await _firebaseArticleService.getArticles();
      final firebaseEntities = firebaseList.map(_firebaseArticleToEntity).toList();

      final combined = [...firebaseEntities, ...mockList]..sort((a, b) =>
          _parseDate(b.publishedAt).compareTo(_parseDate(a.publishedAt)));

      return Right(combined);
    } on FirebaseException catch (e) {
      return Left(mapFirebaseErrorToFailure(e));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error'));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return List<ArticleEntity>.from(_savedArticles);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    _savedArticles.add(article);
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    _savedArticles
        .removeWhere((a) => a.id == article.id && a.url == article.url);
  }

  static DateTime _parseDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) {
      return DateTime.utc(0);
    }
    try {
      return DateTime.parse(publishedAt);
    } catch (_) {
      return DateTime.utc(0);
    }
  }

  static ArticleEntity _firebaseArticleToEntity(ArticleDraftModel draft) {
    return ArticleEntity(
      id: draft.id.hashCode,
      author: draft.author,
      title: draft.title,
      description: draft.description,
      urlToImage: draft.urlToImage,
      publishedAt: draft.publishedAt,
      content: draft.content,
    );
  }

}
