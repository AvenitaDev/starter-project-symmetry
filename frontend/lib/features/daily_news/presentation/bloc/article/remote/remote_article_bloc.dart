import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  Future<void> onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());

    final result = await _getArticleUseCase();

    result.fold(
      (failure) => emit(RemoteArticlesError(failure.message)),
      (articles) => emit(RemoteArticlesDone(articles)),
    );
  }
}
