// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppArticleDraftDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppArticleDraftDatabaseBuilder databaseBuilder(String name) =>
      _$AppArticleDraftDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppArticleDraftDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppArticleDraftDatabaseBuilder(null);
}

class _$AppArticleDraftDatabaseBuilder {
  _$AppArticleDraftDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppArticleDraftDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppArticleDraftDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppArticleDraftDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppArticleDraftDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppArticleDraftDatabase extends AppArticleDraftDatabase {
  _$AppArticleDraftDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleDraftDao? _articleDraftDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `article_draft` (`id` TEXT NOT NULL, `author` TEXT, `title` TEXT, `description` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDraftDao get articleDraftDao {
    return _articleDraftDaoInstance ??=
        _$ArticleDraftDao(database, changeListener);
  }
}

class _$ArticleDraftDao extends ArticleDraftDao {
  _$ArticleDraftDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _articleDraftModelInsertionAdapter = InsertionAdapter(
            database,
            'article_draft',
            (ArticleDraftModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content
                }),
        _articleDraftModelDeletionAdapter = DeletionAdapter(
            database,
            'article_draft',
            ['id'],
            (ArticleDraftModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleDraftModel> _articleDraftModelInsertionAdapter;

  final DeletionAdapter<ArticleDraftModel> _articleDraftModelDeletionAdapter;

  @override
  Future<ArticleDraftModel?> getArticleDraft() async {
    return _queryAdapter.query('SELECT * FROM article_draft LIMIT 1',
        mapper: (Map<String, Object?> row) => ArticleDraftModel(
            id: row['id'] as String,
            author: row['author'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            urlToImage: row['urlToImage'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?));
  }

  @override
  Future<void> insertArticleDraft(ArticleDraftModel articleDraft) async {
    await _articleDraftModelInsertionAdapter.insert(
        articleDraft, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteArticleDraft(ArticleDraftModel articleDraftModel) async {
    await _articleDraftModelDeletionAdapter.delete(articleDraftModel);
  }
}
