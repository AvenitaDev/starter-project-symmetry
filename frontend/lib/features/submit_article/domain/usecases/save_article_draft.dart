import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/repository/submit_article_repository.dart';

import '../../../../core/error/failure.dart';

class SaveArticleDraftUseCase
    implements UseCase<Either<Failure, void>, ArticleDraftEntity> {
  final SubmitArticleRepository _submitArticleRepository;

  SaveArticleDraftUseCase(this._submitArticleRepository);

  @override
  Future<Either<Failure, void>> call(
      {required ArticleDraftEntity params}) async {
    final articleWithId = ArticleDraftEntity(
      id: "unique",
      author: params.author ?? "",
      title: params.title ?? "",
      description: params.description ?? "",
      urlToImage: params.urlToImage ?? "",
      publishedAt: params.publishedAt,
      content: params.content ?? "",
    );
    return _submitArticleRepository.saveArticleDraft(articleWithId);
  }
}
