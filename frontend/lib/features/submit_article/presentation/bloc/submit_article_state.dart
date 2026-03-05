import 'package:news_app_clean_architecture/features/submit_article/domain/entities/article_draft.dart';

class SubmitArticleState {
  final bool isLoadingDraft;
  final bool isSubmitting;
  final bool isSavingDraft;
  final bool saveDraftError;
  final String? errorMessage;
  final bool submitSuccess;
  final bool saveDraftSuccess;
  final ArticleDraftEntity? draft;

  const SubmitArticleState({
    this.isLoadingDraft = false,
    this.isSubmitting = false,
    this.isSavingDraft = false,
    this.saveDraftError = false,
    this.errorMessage,
    this.submitSuccess = false,
    this.saveDraftSuccess = false,
    this.draft,
  });

  SubmitArticleState copyWith({
    bool? isLoadingDraft,
    bool? isSubmitting,
    bool? isSavingDraft,
    bool? saveDraftError,
    String? errorMessage,
    bool? submitSuccess,
    bool? saveDraftSuccess,
    ArticleDraftEntity? draft,
  }) {
    return SubmitArticleState(
      isLoadingDraft: isLoadingDraft ?? this.isLoadingDraft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      saveDraftError: saveDraftError ?? this.saveDraftError,
      errorMessage: errorMessage,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      saveDraftSuccess: saveDraftSuccess ?? this.saveDraftSuccess,
      draft: draft ?? this.draft,
    );
  }
}
