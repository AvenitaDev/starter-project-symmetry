import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/data/repository/article_repository_impl.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/submit_article/data/data_sources/local/app_database.dart';
import 'features/submit_article/data/data_sources/remote/firebase_service.dart';
import 'features/submit_article/data/repository/article_draft_repository_impl.dart';
import 'features/submit_article/domain/repository/submit_article_repository.dart';
import 'features/submit_article/domain/usecases/get_article_draft.dart';
import 'features/submit_article/domain/usecases/save_article_draft.dart';
import 'features/submit_article/domain/usecases/submit_article.dart';
import 'features/submit_article/domain/usecases/upload_article_image.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  final articleDraftDatabase = await $FloorAppArticleDraftDatabase
      .databaseBuilder('article_draft_database.db')
      .build();
  sl.registerSingleton<AppArticleDraftDatabase>(articleDraftDatabase);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirebaseArticleService>(FirebaseArticleService());

  sl.registerSingleton<ArticleRepository>(
      ArticleRepositoryImpl(sl(), sl(), sl()));

  sl.registerSingleton<SubmitArticleRepository>(
      SubmitArticleRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<UploadArticleImageUseCase>(
      UploadArticleImageUseCase(sl()));
  sl.registerSingleton<SubmitArticleUseCase>(SubmitArticleUseCase(sl(), sl()));

  sl.registerSingleton<SaveArticleDraftUseCase>(SaveArticleDraftUseCase(sl()));

  sl.registerSingleton<GetArticleDraftUseCase>(GetArticleDraftUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));
}
