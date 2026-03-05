
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/data_sources/local/DAO/article_draft_dao.dart';
import '../../models/article_draft.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 1, entities: [ArticleDraftModel])
abstract class AppArticleDraftDatabase extends FloorDatabase {
  ArticleDraftDao get articleDraftDao;
}