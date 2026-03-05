import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/submit_article/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/submit_article/presentation/bloc/submit_article_cubit.dart';
import 'package:news_app_clean_architecture/features/submit_article/presentation/bloc/submit_article_state.dart';
import 'package:news_app_clean_architecture/features/submit_article/presentation/pages/markdown_editor_page.dart';

class SubmitArticlePage extends StatefulWidget {
  const SubmitArticlePage({super.key});

  @override
  State<SubmitArticlePage> createState() => _SubmitArticlePageState();
}

class _SubmitArticlePageState extends State<SubmitArticlePage> {
  final _formKey = GlobalKey<FormState>();

  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  bool _controllersInitializedFromDraft = false;
  String? _pickedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  Timer? _debounceTimer;
  bool _pendingDraftSave = false;
  bool _isDebouncing = false;

  static bool _isLocalImagePath(String? path) =>
      path != null && path.isNotEmpty;

  void _fillControllersFromDraft(ArticleDraftEntity draft) {
    if (_controllersInitializedFromDraft) return;
    _controllersInitializedFromDraft = true;
    if (draft.author != null) _authorController.text = draft.author!;
    if (draft.title != null) _titleController.text = draft.title!;
    if (draft.description != null) {
      _descriptionController.text = draft.description!;
    }
    if (draft.content != null) _contentController.text = draft.content!;
    if (_isLocalImagePath(draft.urlToImage)) {
      final path = draft.urlToImage!;
      if (File(path).existsSync()) {
        _pickedImagePath = path;
      }
    }
  }

  ArticleDraftEntity _buildArticleDraft() {
    final now = DateTime.now().toUtc();
    final formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(now);

    return ArticleDraftEntity(
      author: "Adrián Vázquez N.",
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      urlToImage: null,
      publishedAt: formattedDate,
      id: '',
    );
  }

  /// Draft for auto-save: empty fields are stored as "".
  /// Saves the local image path so the draft restores the selected image.
  ArticleDraftEntity _buildDraftForAutoSave() {
    return ArticleDraftEntity(
      id: '',
      author: "Adrián Vázquez N.",
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      urlToImage: _pickedImagePath,
      publishedAt: "now",
    );
  }

  void _onDraftChanged() {
    _debounceTimer?.cancel();
    setState(() => _isDebouncing = true);
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isDebouncing = false;
        _pendingDraftSave = true;
      });
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final persistentPath = await _copyToDraftImagePath(file.path);
    if (persistentPath == null || !mounted) return;
    setState(() {
      _pickedImagePath = persistentPath;
    });
    _onDraftChanged();
  }

  /// Copies the picked image to app documents so it persists for the draft.
  /// Returns the new path, or null on failure.
  Future<String?> _copyToDraftImagePath(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final draftDir = Directory('${dir.path}/draft_images');
      if (!await draftDir.exists()) await draftDir.create(recursive: true);
      final parts = sourcePath.split('.');
      final extension = parts.length > 1 ? parts.last : 'jpg';
      final destPath = '${draftDir.path}/draft_cover.$extension';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  void _openContentEditor() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (context) => MarkdownEditorPage(
              controller: _contentController,
              fieldLabel: 'Content',
            ),
          ),
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<SubmitArticleCubit>().submit(
          _buildArticleDraft(),
          imageFilePath: _pickedImagePath,
        );
  }

  @override
  void initState() {
    super.initState();
    _authorController.addListener(_onDraftChanged);
    _titleController.addListener(_onDraftChanged);
    _descriptionController.addListener(_onDraftChanged);
    _contentController.addListener(_onDraftChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _authorController.removeListener(_onDraftChanged);
    _titleController.removeListener(_onDraftChanged);
    _descriptionController.removeListener(_onDraftChanged);
    _contentController.removeListener(_onDraftChanged);
    _authorController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmitArticleCubit, SubmitArticleState>(
      listener: (context, state) {
        if (state.draft != null) {
          _fillControllersFromDraft(state.draft!);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.saveDraftSuccess) {
          context.read<SubmitArticleCubit>().clearSaveDraftSuccess();
        }
        if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article submitted successfully')),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        if (_pendingDraftSave && context.mounted) {
          _pendingDraftSave = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context
                  .read<SubmitArticleCubit>()
                  .saveDraft(_buildDraftForAutoSave());
            }
          });
        }
        if (state.isLoadingDraft) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Submit article',
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              elevation: 0.5,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final showDraftLoading = _isDebouncing || state.isSavingDraft;
        final showDraftError = state.saveDraftError;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Submit article',
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: [
              if (showDraftLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: SizedBox(
                    width: 56,
                    height: 12,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (showDraftError)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.close,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _HeaderImagePreview(
                  pickedImagePath: _pickedImagePath,
                  onPickImage: _pickImageFromGallery,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Form(
                            key: _formKey,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Title',
                                    controller: _titleController,
                                    maxLength: 50,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Title is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    label: 'Short description',
                                    controller: _descriptionController,
                                    hint: '1-2 sentence summary',
                                    maxLines: 3,
                                    maxLength: 120,
                                  ),
                                  _buildContentField(),
                                  const SizedBox(height: 88),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed:
                      state.isSubmitting ? null : () => _onSubmit(context),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Publish', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentField() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        validator: (_) {
          if (_contentController.text.trim().isEmpty) {
            return 'Content is required';
          }
          return null;
        },
        builder: (state) {
          final hasError = state.hasError;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Content',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  side: BorderSide(
                    color: hasError ? theme.colorScheme.error : Colors.grey.shade400,
                    width: hasError ? 1.5 : 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.grey.shade50,
                ),
                onPressed: _openContentEditor,
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _contentController.text.isEmpty
                            ? 'Write the full article body in Markdown'
                            : _contentController.text.replaceAll('\n', ' ').trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _contentController.text.isEmpty
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 6),
                Text(
                  state.errorText ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(14);

    final field = TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: maxLines > 1 ? 1.4 : null,
      ),
      decoration: InputDecoration(
        labelText: maxLength != null
            ? '$label   ${controller.text.length} / $maxLength'
            : label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 14,
        ),
        border: OutlineInputBorder(borderRadius: borderRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        counterText: '',
      ),
    );

    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: field,
      );
  }
}

const _heroTagSubmitImage = 'submit_article_preview_image';

class _HeaderImagePreview extends StatelessWidget {
  const _HeaderImagePreview({
    required this.pickedImagePath,
    required this.onPickImage,
  });

  final String? pickedImagePath;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 250,
        color: Colors.grey.shade200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (pickedImagePath != null)
              Hero(
                tag: _heroTagSubmitImage,
                child: Image.file(
                  File(pickedImagePath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              const _EmptyImageState(
                message: 'Tap to choose an image from the gallery',
              ),
            if (pickedImagePath != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => _PhotoViewPage(
                            imagePath: pickedImagePath!,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            if (pickedImagePath != null)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        'Tap to change image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewPage extends StatelessWidget {
  const _PhotoViewPage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Image',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Hero(
        tag: _heroTagSubmitImage,
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
    return content;
  }
}
