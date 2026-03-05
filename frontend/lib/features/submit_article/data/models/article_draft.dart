import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

import '../../domain/entities/article_draft.dart';

@Entity(tableName: 'article_draft', primaryKeys: ['id'])
class ArticleDraftModel extends ArticleDraftEntity {
  const ArticleDraftModel({
    required super.id,
    super.author,
    super.title,
    super.description,
    super.urlToImage,
    super.publishedAt,
    super.content,
  });

  factory ArticleDraftModel.fromJson(Map<String, dynamic> map) {
    return ArticleDraftModel(
      id: map['id'],
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleDraftModel.fromEntity(ArticleDraftEntity entity) {
    return ArticleDraftModel(
      id: entity.id,
      author: entity.author ?? '',
      title: entity.title ?? '',
      description: entity.description ?? '',
      urlToImage: entity.urlToImage ?? '',
      publishedAt: entity.publishedAt ?? '',
      content: entity.content ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}
