import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/usecases/get_article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/usecases/save_article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/usecases/submit_article.dart';
import 'package:news_app_clean_architecture/features/submit_article/presentation/bloc/submit_article_state.dart';

class SubmitArticleCubit extends Cubit<SubmitArticleState> {
  final GetArticleDraftUseCase _getDraft;
  final SaveArticleDraftUseCase _saveDraft;
  final SubmitArticleUseCase _submit;

  SubmitArticleCubit(
    this._getDraft,
    this._saveDraft,
    this._submit,
  ) : super(const SubmitArticleState());

  Future<void> loadDraft() async {
    emit(state.copyWith(isLoadingDraft: true));

    final result = await _getDraft(params: const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingDraft: false,
          errorMessage: failure.message,
        ),
      ),
      (draft) => emit(
        state.copyWith(
          isLoadingDraft: false,
          draft: draft,
        ),
      ),
    );
  }

  Future<void> saveDraft(ArticleDraftEntity article) async {
    emit(state.copyWith(isSavingDraft: true, saveDraftError: false));

    final result = await _saveDraft(params: article);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSavingDraft: false,
          saveDraftError: true,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(isSavingDraft: false, saveDraftSuccess: true),
      ),
    );
  }

  void clearSaveDraftSuccess() {
    emit(state.copyWith(saveDraftSuccess: false));
  }

  Future<void> submit(ArticleDraftEntity article, {String? imageFilePath}) async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _submit(
      params: SubmitArticleParams(
        article: article,
        imageFilePath: imageFilePath,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: true,
        ),
      ),
    );
  }
}
