import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article',primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int ? id,
    String ? author,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
  }): super(
    id: id,
    author: author,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
  );

  factory ArticleModel.fromJson(Map < String, dynamic > map) {
    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != "" ? map['urlToImage'] : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    final id = entity.id ?? _generatePredictableId(entity);

    return ArticleModel(
      id: id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  static int _generatePredictableId(ArticleEntity entity) {
    final parts = <String>[
      entity.url ?? '',
      entity.title ?? '',
      entity.author ?? '',
      entity.publishedAt ?? '',
      entity.description ?? '',
      entity.content ?? '',
      entity.urlToImage ?? '',
    ];

    final key = parts.where((p) => p.isNotEmpty).join('|');

    if (key.isEmpty) {
      return 0;
    }

    return key.hashCode;
  }
}