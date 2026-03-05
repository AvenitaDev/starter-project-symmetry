import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/data_sources/remote/firebase_service.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/models/article_draft.dart';

import '../../../../core/error/exceptions.dart';
import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirebaseArticleService _firebaseArticleService;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._appDatabase,
    this._firebaseArticleService,
  );

  @override
  Future<Either<Failure, List<ArticleEntity>>> getNewsArticles() async {
    Failure? lastFailure;

    final apiArticles = await _fetchApiArticles().catchError(
      (e) => lastFailure = e,
    );

    final firebaseArticles = await _fetchFirebaseArticles().catchError(
      (e) => lastFailure ??= e,
    );

    final combined = [...firebaseArticles, ...apiArticles]
      ..sort((a, b) => _parseDate(b.publishedAt).compareTo(_parseDate(a.publishedAt)));

    if (combined.isEmpty && lastFailure != null) return Left(lastFailure!);

    return Right(combined);
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() =>
      _appDatabase.articleDAO.getArticles();

  @override
  Future<void> removeArticle(ArticleEntity article) =>
      _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));

  @override
  Future<void> saveArticle(ArticleEntity article) =>
      _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));

  // --- Private helpers ---
  Future<List<ArticleModel>> _fetchApiArticles() async {
    try {
      final response = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );
      return response.data;
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    } catch (e, st) {
      log('Unexpected error from News API: $e', stackTrace: st);
      throw const UnexpectedFailure('Unexpected error');
    }
  }

  Future<List<ArticleEntity>> _fetchFirebaseArticles() async {
    try {
      final list = await _firebaseArticleService.getArticles();
      return list.map(_firebaseArticleToEntity).toList(growable: false);
    } on FirebaseException catch (e) {
      throw mapFirebaseErrorToFailure(e);
    } catch (e, st) {
      log('Unexpected error from Firebase: $e', stackTrace: st);
      throw const UnexpectedFailure('Unexpected error');
    }
  }

  static DateTime _parseDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return DateTime.utc(0);
    try {
      return DateTime.parse(publishedAt);
    } catch (_) {
      return DateTime.utc(0);
    }
  }

  static ArticleEntity _firebaseArticleToEntity(ArticleDraftModel draft) =>
      ArticleEntity(
        id: draft.id.hashCode,
        author: draft.author,
        title: draft.title,
        description: draft.description,
        urlToImage: draft.urlToImage,
        publishedAt: draft.publishedAt,
        content: draft.content,
      );
}