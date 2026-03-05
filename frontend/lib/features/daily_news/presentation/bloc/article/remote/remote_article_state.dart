import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';

//This state is used to manage the state of the remote articles
//Empty List of Articles is the initial state
abstract class RemoteArticlesState extends Equatable {
  const RemoteArticlesState();

  @override
  List<Object?> get props => [];
}


class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  final List<ArticleEntity> articles;

  const RemoteArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class RemoteArticlesError extends RemoteArticlesState {
  final String message;

  const RemoteArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}