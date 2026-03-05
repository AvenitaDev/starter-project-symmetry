import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/article_draft.dart';

abstract class SubmitArticleRepository {
  // API methods
  Future<Either<Failure, void>> submitArticle(ArticleDraftEntity article);

  /// Uploads article cover image to Storage; returns the storage path.
  Future<Either<Failure, String>> uploadArticleImage(
      String articleId, String imageFilePath);

  // Database methods
  Future < Either<Failure, ArticleDraftEntity?> > getArticleDraft();

  Future<Either<Failure, void>> saveArticleDraft(ArticleDraftEntity article);

  Future<Either<Failure, void>> deleteArticleDraft();
}