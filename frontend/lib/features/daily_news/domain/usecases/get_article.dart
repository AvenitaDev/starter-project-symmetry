import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../../../../core/error/failure.dart';

class GetArticleUseCase implements UseCase<Either<Failure, List<ArticleEntity>>,void>{
  
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);
  
  @override
  Future<Either<Failure, List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getNewsArticles();
  }
}
