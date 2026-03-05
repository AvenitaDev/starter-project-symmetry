import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Pantalla para editar contenido en Markdown con vista previa y barra de formato.
class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({
    super.key,
    required this.controller,
    this.fieldLabel = 'Content',
  });

  final TextEditingController controller;
  final String fieldLabel;

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _showPreview = false;

  void _wrapSelection(String prefix, String suffix) {
    final c = widget.controller;
    final sel = c.selection;
    final start = sel.start;
    final end = sel.end;
    final text = c.text;
    String newText;
    int newCursor;
    if (start < end) {
      final selected = text.substring(start, end);
      newText = '${text.substring(0, start)}$prefix$selected$suffix${text.substring(end)}';
      newCursor = start + prefix.length + selected.length + suffix.length;
    } else {
      newText = '${text.substring(0, start)}$prefix$suffix${text.substring(start)}';
      newCursor = start + prefix.length;
    }
    c.text = newText;
    c.selection = TextSelection.collapsed(offset: newCursor);
  }

  void _insertAtLineStart(String prefix) {
    final c = widget.controller;
    final text = c.text;
    final pos = c.selection.baseOffset;
    final before = text.substring(0, pos);
    final lineStart = before.lastIndexOf('\n') + 1;
    final newText = '${text.substring(0, lineStart)}$prefix${text.substring(lineStart)}';
    c.text = newText;
    c.selection = TextSelection.collapsed(offset: lineStart + prefix.length);
  }

  void _header(int level) {
    final prefix = '${'#' * level} ';
    _insertAtLineStart(prefix);
  }

  void _bulletList() {
    _insertAtLineStart('- ');
  }

  void _numberedList() {
    _insertAtLineStart('1. ');
  }

  void _sublist() {
    _insertAtLineStart('  - ');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final previewTitle = '${widget.fieldLabel} preview';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showPreview ? previewTitle : widget.fieldLabel,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showPreview = !_showPreview),
            icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
            tooltip: _showPreview ? 'Ocultar vista previa' : 'Mostrar vista previa',
          ),
        ],
      ),
      body: _showPreview
          ? SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: MarkdownBody(
                data: widget.controller.text.isEmpty
                    ? '_No content yet_'
                    : widget.controller.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyLarge,
                  h1: theme.textTheme.headlineMedium,
                  h2: theme.textTheme.titleLarge,
                  h3: theme.textTheme.titleMedium,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write Markdown here...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tooltipButton('B', 'Bold', Icons.format_bold, () => _wrapSelection('**', '**')),
                        _tooltipButton('I', 'Italic', Icons.format_italic, () => _wrapSelection('*', '*')),
                        _tooltipButton('S', 'Strikethrough', Icons.format_strikethrough, () => _wrapSelection('~~', '~~')),
                        _tooltipButton('Code', 'Inline code', Icons.code, () => _wrapSelection('`', '`')),
                        const SizedBox(width: 8),
                        _headersMenuButton(),
                        const SizedBox(width: 8),
                        _tooltipButton('•', 'Bulleted list', Icons.format_list_bulleted, _bulletList),
                        _tooltipButton('1.', 'Numbered list', Icons.format_list_numbered, _numberedList),
                        _tooltipButton('↳', 'Sublist/Indent', Icons.format_indent_increase, _sublist),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _headersMenuButton() {
    return Builder(
      builder: (buttonContext) {
        return Tooltip(
          message: 'Encabezados',
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final box = buttonContext.findRenderObject() as RenderBox?;
                if (box == null) return;
                final pos = box.localToGlobal(Offset.zero);
                final size = box.size;
                final relativeRect = RelativeRect.fromLTRB(
                  pos.dx,
                  pos.dy + size.height,
                  pos.dx + size.width,
                  pos.dy + size.height + 1,
                );
                final level = await showMenu<int>(
                  context: buttonContext,
                  position: relativeRect,
                  items: [
                    const PopupMenuItem(value: 1, child: Text('H1  Título 1')),
                    const PopupMenuItem(value: 2, child: Text('H2  Título 2')),
                    const PopupMenuItem(value: 3, child: Text('H3  Título 3')),
                  ],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
                if (level != null && mounted) _header(level);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  'H',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tooltipButton(String label, String tooltip, IconData? icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: icon != null
                  ? Icon(icon, size: 22, color: Colors.grey.shade800)
                  : Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
