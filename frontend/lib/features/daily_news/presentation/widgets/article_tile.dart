import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/helpers/formaters.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
            start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    try {
      final url = article?.urlToImage;
      if (url == null || url.isEmpty) {
        return _buildErrorImage(context);
      }

      return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) =>
            _buildImageContainer(context, imageProvider),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            _buildLoadingContainer(context),
        errorWidget: (context, url, error) => _buildErrorImage(context),
      );
    } catch (e) {
      return _buildErrorImage(context);
    }
  }

  Widget _buildImageContainer(
      BuildContext context, ImageProvider imageProvider) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator(),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: double.maxFinite,
          alignment: Alignment.center,
          child: const Icon(Icons.error),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article!.title ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Butler',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            // Author (if present)
            if (article!.author != null && article!.author!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  article!.author!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),

            // Description or content (converted from Markdown) if description is empty
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: (article!.description != null &&
                        article!.description!.trim().isNotEmpty)
                    ? Text(
                        article!.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        _plainTextFromMarkdown(article!.content),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
              ),
            ),

            // Datetime
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  formatPublishedAt(article!.publishedAt),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable!) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      );
    }
    return Container();
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }

  String _plainTextFromMarkdown(String? markdown) {
    if (markdown == null || markdown.trim().isEmpty) {
      return '';
    }

    var text = markdown;

    // Remove bold (**text** or __text__)
    text = text.replaceAllMapped(
      RegExp(r'(\*\*|__)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );

    // Remove italics (*text* or _text_)
    text = text.replaceAllMapped(
      RegExp(r'(\*|_)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );

    // Inline code `code`
    text = text.replaceAllMapped(
      RegExp(r'`([^`]*)`'),
      (match) => match.group(1) ?? '',
    );

    // Images ![alt](url) -> removed
    text = text.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');

    // Links [text](url) -> text
    text = text.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      (match) => match.group(1) ?? '',
    );

    // Headings starting with #, ##, etc.
    text = text.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');

    // List markers -, *, +
    text = text.replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '');

    // Collapse whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }
}
