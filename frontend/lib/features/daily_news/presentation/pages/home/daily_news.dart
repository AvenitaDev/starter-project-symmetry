import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppbar(context),
      body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
          if (state is RemoteArticlesLoading) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (state is RemoteArticlesError) {
            return _buildErrorState(context, state.message);
          }

          if (state is RemoteArticlesDone) {
            return _buildArticlesList(context, state.articles);
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/SubmitArticle');
          if (result == true && context.mounted) {
            context.read<RemoteArticlesBloc>().add(const GetArticles());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  // ---------------- ARTICLES LIST ----------------

  Widget _buildArticlesList(
      BuildContext context, List<ArticleEntity> articles) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<RemoteArticlesBloc>();
        bloc.add(const GetArticles());
        await bloc.stream
            .where((s) => s is RemoteArticlesDone || s is RemoteArticlesError)
            .first;
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];

          return ArticleWidget(
            article: article,
            onArticlePressed: (article) =>
                _onArticlePressed(context, article),
          );
        },
      ),
    );
  }

  // ---------------- ERROR ----------------

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<RemoteArticlesBloc>()
                  .add(const GetArticles());
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // ---------------- NAVIGATION ----------------

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(
      context,
      '/ArticleDetails',
      arguments: article,
    );
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}