import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/article_draft.dart';
import '../../domain/repository/submit_article_repository.dart';
import '../data_sources/local/app_database.dart';
import '../data_sources/remote/firebase_service.dart';
import '../models/article_draft.dart';

class SubmitArticleRepositoryImpl implements SubmitArticleRepository {
  final FirebaseArticleService _firebaseService;
  final AppArticleDraftDatabase _appDatabase;

  SubmitArticleRepositoryImpl(
      this._firebaseService,
      this._appDatabase,
  );

  @override
  Future<Either<Failure, void>> submitArticle(
      ArticleDraftEntity article) async {
    try {
      await _firebaseService
          .addArticle(ArticleDraftModel.fromEntity(article));

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(mapFirebaseErrorToFailure(e));
    } on TimeoutException catch (_) {
      return const Left(NetworkFailure('Timeout error, please try again later'));
    } catch (_) {
      return const Left(UnexpectedFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadArticleImage(
      String articleId, String imageFilePath) async {
    try {
      final url =
          await _firebaseService.uploadArticleImage(articleId, imageFilePath);
      return Right(url);
    } on FirebaseException catch (e) {
      return Left(mapFirebaseErrorToFailure(e));
    } catch (_) {
      return const Left(UnexpectedFailure('Failed to upload image'));
    }
  }

  @override
  Future<Either<Failure, ArticleDraftEntity?>> getArticleDraft() async {
    try {
      final draft = await _appDatabase.articleDraftDao.getArticleDraft();
      return Right(draft);
    } catch (_) {
      return const Left(UnexpectedFailure('Failed to get draft'));
    }
  }

  @override
  Future<Either<Failure, void>> saveArticleDraft(
      ArticleDraftEntity article) async {
    try {
      await _appDatabase.articleDraftDao.insertArticleDraft(
        ArticleDraftModel.fromEntity(article)
      );
      return const Right(null);
    } catch (_) {
      return const Left(UnexpectedFailure('Failed to save draft'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArticleDraft() async {
    try {
      final draft = await _appDatabase.articleDraftDao.getArticleDraft();
      if (draft != null) {
        await _appDatabase.articleDraftDao.deleteArticleDraft(draft);
      }
      return const Right(null);
    } catch (_) {
      // Draft cleanup should never crash the app; surface a controlled failure.
      return const Left(UnexpectedFailure('Failed to delete draft'));
    }
  }
}