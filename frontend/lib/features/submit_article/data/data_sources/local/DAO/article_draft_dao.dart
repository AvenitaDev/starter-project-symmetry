import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/models/article_draft.dart';

@dao
abstract class ArticleDraftDao {
  
  /// Upsert: replace on conflict (by primary key, which should be id)
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticleDraft(ArticleDraftModel articleDraft);
  
  @delete
  Future<void> deleteArticleDraft(ArticleDraftModel articleDraftModel);
  
  @Query('SELECT * FROM article_draft LIMIT 1')
  Future<ArticleDraftModel?> getArticleDraft();
}