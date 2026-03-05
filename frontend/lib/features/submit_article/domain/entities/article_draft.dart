import 'package:equatable/equatable.dart';

class ArticleDraftEntity extends Equatable {
  final String id;
  final String? author;
  final String? title;
  final String? description;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleDraftEntity({
    required this.id,
    this.author,
    this.title,
    this.description,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  @override
  List<Object?> get props => [
        id,
        author,
        title,
        description,
        urlToImage,
        publishedAt,
        content,
      ];

  
}
