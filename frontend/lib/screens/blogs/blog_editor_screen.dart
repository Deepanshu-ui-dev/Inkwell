import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/providers/blog_provider.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/utils/validators.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class BlogEditorScreen extends StatefulWidget {
  final BlogModel? blog;
  const BlogEditorScreen({super.key, this.blog});
  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _tagInputController = TextEditingController();
  List<String> _tags = [];
  bool _isPublished = true;
  bool _isSaving = false;
  bool _showCoverInput = false;

  bool get _isEditing => widget.blog != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.blog!;
      _titleController.text = b.title;
      _contentController.text = b.content;
      _coverUrlController.text = b.coverImageUrl ?? '';
      _tags = List<String>.from(b.tags);
      _isPublished = b.published;
      if (b.coverImageUrl != null && b.coverImageUrl!.isNotEmpty) _showCoverInput = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _coverUrlController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.trim().toLowerCase().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagInputController.clear();
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final payload = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'coverImageUrl': _coverUrlController.text.trim().isEmpty
          ? null : _coverUrlController.text.trim(),
      'coverImage': _coverUrlController.text.trim().isEmpty
          ? null : _coverUrlController.text.trim(), // Backend expects coverImage
      'tags': _tags,
      'published': _isPublished,
    };

    final blogProvider = context.read<BlogProvider>();
    BlogModel? result;
    if (_isEditing) {
      result = await blogProvider.updateBlog(widget.blog!.id, payload);
    } else {
      result = await blogProvider.createBlog(payload);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null) {
      AppSnackbar.show(context, message: _isEditing ? 'Story updated ✓' : 'Story published!');
      Navigator.pop(context);
      if (!_isEditing) {
        Navigator.pushNamed(context, AppConstants.routeBlogDetail, arguments: result.id);
      }
    } else {
      AppSnackbar.show(context,
          message: blogProvider.errorMessage ?? 'Failed to save', isError: true);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    if (!mounted) return;
    AppSnackbar.show(context, message: 'Uploading image...');

    try {
      final blogService = context.read<BlogProvider>().blogService; // need to expose blogService if not exposed
      String imageUrl;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        imageUrl = await blogService.uploadImage(pickedFile.path, pickedFile.name, bytes: bytes);
      } else {
        imageUrl = await blogService.uploadImage(pickedFile.path, pickedFile.name);
      }
      
      setState(() {
        _coverUrlController.text = imageUrl;
        _showCoverInput = true;
      });
      if (mounted) AppSnackbar.show(context, message: 'Image uploaded successfully!');
    } catch (e) {
      if (mounted) AppSnackbar.show(context, message: 'Upload failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 26, color: context.colors.ink),
          onPressed: _showDiscardDialog,
        ),
        title: Text(_isEditing ? 'Edit story' : 'New story', style: context.typography.titleLarge),
        actions: [
          // Published toggle
          GestureDetector(
            onTap: () => setState(() => _isPublished = !_isPublished),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _isPublished ? context.colors.accent : context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.ink, width: 2),
                boxShadow: [
                  BoxShadow(color: context.colors.ink, offset: Offset(2, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPublished)
                    Icon(Icons.check_rounded, size: 14, color: context.colors.ink),
                  if (_isPublished) SizedBox(width: 4),
                  Text(
                    _isPublished ? 'Published' : 'Draft',
                    style: context.typography.labelLarge.copyWith(
                      color: context.colors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Save button
          Padding(
            padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: GestureDetector(
              key: const Key('save_blog_button'),
              onTap: _isSaving ? null : _save,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: context.colors.ink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.ink, width: 2),
                  boxShadow: [
                    BoxShadow(color: context.colors.ink, offset: Offset(2, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSaving
                    ? SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.accent))
                    : Text(
                        _isEditing ? 'Update' : 'Publish',
                        style: context.typography.labelLarge.copyWith(
                            color: context.colors.surfaceWhite, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveWrapper(
          maxWidth: 720,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 80),
            children: [
              // ── Cover image banner ──────────────────────────────────
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.ink, width: 2),
                    boxShadow: [
                      BoxShadow(color: context.colors.ink, offset: Offset(4, 4)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _coverUrlController.text.trim().isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _coverUrlController.text.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _coverPlaceholder(),
                            ),
                            Positioned(
                              top: 12, right: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: context.colors.ink.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Change Cover', style: context.typography.bodySmall.copyWith(color: context.colors.surfaceWhite)),
                              ),
                            ),
                          ],
                        )
                      : _coverPlaceholder(),
                ),
              ),

              // Cover URL input (shown when tapped)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _showCoverInput
                    ? Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: TextFormField(
                          key: const Key('editor_cover_url_field'),
                          controller: _coverUrlController,
                          keyboardType: TextInputType.url,
                          style: context.typography.bodyMedium.copyWith(color: context.colors.ink),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Paste cover image URL…',
                            prefixIcon: Icon(Icons.link_rounded, size: 20, color: context.colors.inkMuted),
                          ),
                          validator: Validators.optionalUrl,
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              
              SizedBox(height: 32),

              // ── Title ───────────────────────────────────────────────
              TextFormField(
                key: const Key('editor_title_field'),
                controller: _titleController,
                style: context.typography.hero.copyWith(fontSize: 48, color: context.colors.ink),
                decoration: InputDecoration(
                  hintText: 'Story title…',
                  hintStyle: context.typography.hero.copyWith(
                      fontSize: 48, color: context.colors.border),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.blogTitle,
              ),

              SizedBox(height: 24),

              // ── Tags ────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _tags.map((t) => _TagChipEditable(
                          tag: t, onRemove: () => _removeTag(t),
                        )).toList(),
                      ),
                    if (_tags.isNotEmpty) SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.tag_rounded, size: 18, color: context.colors.inkMuted),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const Key('editor_tags_field'),
                            controller: _tagInputController,
                            style: context.typography.bodyMedium.copyWith(color: context.colors.ink),
                            decoration: InputDecoration(
                              hintText: 'Add a tag and press Enter',
                              hintStyle: context.typography.bodyMedium,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onSubmitted: _addTag,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // ── Content ─────────────────────────────────────────────
              TextFormField(
                key: const Key('editor_content_field'),
                controller: _contentController,
                style: context.typography.bodyLarge.copyWith(height: 1.8),
                maxLines: null,
                minLines: 12,
                decoration: InputDecoration(
                  hintText: 'Write your story here…\n\nUse # for headings, **bold**, _italic_',
                  hintStyle: context.typography.bodyLarge.copyWith(height: 1.8, color: context.colors.inkMuted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: Validators.blogContent,
                textCapitalization: TextCapitalization.sentences,
              ),

              SizedBox(height: 40),
              
              // Markdown hint
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: context.colors.inkMuted),
                  SizedBox(width: 8),
                  Text('Markdown fully supported for rich formatting.', style: context.typography.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: context.colors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.ink, width: 2),
            boxShadow: [BoxShadow(color: context.colors.ink, offset: Offset(2, 2))],
          ),
          child: Icon(Icons.add_photo_alternate_rounded, size: 24, color: context.colors.ink),
        ),
        SizedBox(height: 12),
        Text('Add a cover image', style: context.typography.labelLarge),
      ],
    );
  }

  Future<void> _showDiscardDialog() async {
    final hasContent = _titleController.text.isNotEmpty || _contentController.text.isNotEmpty;
    if (!hasContent) { Navigator.pop(context); return; }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.ink, width: 2),
        ),
        title: Text('Discard changes?', style: context.typography.titleLarge),
        content: Text('Your changes won\'t be saved.', style: context.typography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            style: TextButton.styleFrom(foregroundColor: context.colors.ink),
            child: Text('Keep editing')
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Discard', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) Navigator.pop(context);
  }
}

class _TagChipEditable extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;
  const _TagChipEditable({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: context.colors.tagBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.tagText, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag, style: context.typography.labelLarge.copyWith(color: context.colors.tagText, fontWeight: FontWeight.w800)),
          SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.tagText,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 10, color: context.colors.tagBg),
            ),
          ),
        ],
      ),
    );
  }
}