import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<ArticleEntity>>> getNewsArticles();

  Future<List<ArticleEntity>> getSavedArticles();
  Future<void> removeArticle(ArticleEntity article);
  Future<void> saveArticle(ArticleEntity article);
}