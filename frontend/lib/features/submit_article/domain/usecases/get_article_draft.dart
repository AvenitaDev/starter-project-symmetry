import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/repository/submit_article_repository.dart';

import '../../../../core/error/failure.dart';

class GetArticleDraftUseCase
    implements UseCase<Either<Failure, ArticleDraftEntity?>, NoParams> {
  final SubmitArticleRepository _submitArticleRepository;

  GetArticleDraftUseCase(this._submitArticleRepository);

  @override
  Future<Either<Failure, ArticleDraftEntity?>> call(
      {required NoParams params}) async {
    return _submitArticleRepository.getArticleDraft();
  }
}
