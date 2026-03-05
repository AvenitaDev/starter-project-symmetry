import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/repository/submit_article_repository.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/usecases/upload_article_image.dart';
import '../../../../core/error/failure.dart';
import '../entities/article_draft.dart';

/// Parameters for [SubmitArticleUseCase]: draft data and optional local image path.
class SubmitArticleParams {
  final ArticleDraftEntity article;
  final String? imageFilePath;

  const SubmitArticleParams({
    required this.article,
    this.imageFilePath,
  });
}

class SubmitArticleUseCase
    implements UseCase<Either<Failure, void>, SubmitArticleParams> {
  final SubmitArticleRepository _submitArticleRepository;
  final UploadArticleImageUseCase _uploadArticleImage;
  final Uuid _uuid = const Uuid();

  SubmitArticleUseCase(this._submitArticleRepository, this._uploadArticleImage);

  @override
  Future<Either<Failure, void>> call(
      {required SubmitArticleParams params}) async {
    final articleId = _uuid.v4();

    if (params.imageFilePath != null &&
        params.imageFilePath!.trim().isNotEmpty) {
      final uploadResult = await _uploadArticleImage(
        params: UploadArticleImageParams(
          articleId: articleId,
          imageFilePath: params.imageFilePath!,
        ),
      );
      return uploadResult.fold(
        (failure) => Future.value(Left(failure)),
        (url) async {
          final articleWithId = ArticleDraftEntity(
            id: articleId,
            author: params.article.author,
            title: params.article.title,
            description: params.article.description,
            urlToImage: url,
            publishedAt: params.article.publishedAt,
            content: params.article.content,
          );

          final submitResult =
              await _submitArticleRepository.submitArticle(articleWithId);

          return submitResult.fold(
            (failure) => Left(failure),
            (_) async {
              // Clear any locally stored draft after a successful submit.
              await _submitArticleRepository.deleteArticleDraft();
              return const Right(null);
            },
          );
        },
      );
    }

    final articleWithId = ArticleDraftEntity(
      id: articleId,
      author: params.article.author,
      title: params.article.title,
      description: params.article.description,
      urlToImage: params.article.urlToImage,
      publishedAt: params.article.publishedAt,
      content: params.article.content,
    );
    final submitResult =
        await _submitArticleRepository.submitArticle(articleWithId);

    return submitResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Clear any locally stored draft after a successful submit.
        await _submitArticleRepository.deleteArticleDraft();
        return const Right(null);
      },
    );
  }
}
