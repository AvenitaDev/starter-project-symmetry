import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/repository/submit_article_repository.dart';
import '../../../../core/error/failure.dart';

/// Parameters for [UploadArticleImageUseCase].
class UploadArticleImageParams {
  final String articleId;
  final String imageFilePath;

  const UploadArticleImageParams({
    required this.articleId,
    required this.imageFilePath,
  });
}

/// Uploads the article cover image to Firebase Storage and returns its storage path.
/// Storage path pattern: media/articles/{articleId}.{extension}
class UploadArticleImageUseCase
    implements UseCase<Either<Failure, String>, UploadArticleImageParams> {
  final SubmitArticleRepository _repository;

  UploadArticleImageUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call({
    required UploadArticleImageParams params,
  }) async {
    return _repository.uploadArticleImage(
      params.articleId,
      params.imageFilePath,
    );
  }
}
