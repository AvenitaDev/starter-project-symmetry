import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/submit_article/domain/usecases/get_article_draft.dart';
import '../../features/submit_article/domain/usecases/save_article_draft.dart';
import '../../features/submit_article/domain/usecases/submit_article.dart';
import '../../features/submit_article/presentation/bloc/submit_article_cubit.dart';
import '../../features/submit_article/presentation/pages/submit_article_page.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _cupertinoRoute(const DailyNews());

      case '/ArticleDetails':
        return _cupertinoRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _cupertinoRoute(const SavedArticles());

      case '/SubmitArticle':
        return _cupertinoRoute(
          BlocProvider(
            create: (_) => SubmitArticleCubit(
              sl<GetArticleDraftUseCase>(),
              sl<SaveArticleDraftUseCase>(),
              sl<SubmitArticleUseCase>(),
            )..loadDraft(),
            child: const SubmitArticlePage(),
          ),
        );

      default:
        return _cupertinoRoute(const DailyNews());
    }
  }

  static Route<dynamic> _cupertinoRoute(Widget view) {
    return CupertinoPageRoute(builder: (_) => view);
  }
}
