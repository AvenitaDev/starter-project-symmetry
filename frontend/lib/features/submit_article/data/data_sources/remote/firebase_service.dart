import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/submit_article/data/models/article_draft.dart';

class FirebaseArticleService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseArticleService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  CollectionReference get articleCollection => firestore.collection("articles");
  CollectionReference get nameCollection => firestore.collection("name");

  Future<void> addArticle(ArticleDraftModel article) async {
    await articleCollection.doc(article.id).set(article.toJson()).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException("No response from Firebase"),
        );
  }

  Future<List<ArticleDraftModel>> getArticles() async {
    final snapshot = await articleCollection.orderBy('publishedAt', descending: true).get();

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final rawImageRef = (data['urlToImage'] as String?)?.trim();
      String? resolvedImageUrl;

      if (rawImageRef != null && rawImageRef.isNotEmpty) {
        if (rawImageRef.startsWith('http')) {
          resolvedImageUrl = rawImageRef;
        } else {
          try {
            resolvedImageUrl =
                await storage.ref().child(rawImageRef).getDownloadURL();
          } catch (_) {
            resolvedImageUrl = null;
          }
        }
      }

      return ArticleDraftModel.fromJson({
        ...data,
        'id': doc.id,
        if (resolvedImageUrl != null && resolvedImageUrl.isNotEmpty)
          'urlToImage': resolvedImageUrl,
      });
    });

    return await Future.wait(futures);
  }

  /// Uploads the article cover image to Storage and returns its storage path.
  /// Path pattern: media/articles/{articleId}.{extension}
  Future<String> uploadArticleImage(String articleId, String filePath) async {
    final file = File(filePath);
    final extension = filePath.split('.').last.toLowerCase();
    final safeExtension =
        ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)
            ? extension
            : 'jpg';

    final storagePath = 'media/articles/$articleId.$safeExtension';
    final ref = storage.ref().child(storagePath);
    await ref.putFile(file);
    return storagePath;
  }
}
