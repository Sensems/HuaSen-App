import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/category_dto.dart';
import '../../data/models/create_category_dto.dart';
import '../../data/models/reorder_item.dart';
import '../../data/models/tag_dtos.dart';
import '../../data/models/update_category_dto.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';

/// Flatten a category tree depth-first for list display and reorder.
List<CategoryDto> flattenCategoryTree(List<CategoryDto> roots) {
  final result = <CategoryDto>[];
  void visit(CategoryDto node) {
    result.add(node.copyWith(children: null));
    for (final child in node.children ?? const <CategoryDto>[]) {
      visit(child);
    }
  }

  for (final root in roots) {
    visit(root);
  }
  return result;
}

/// Manage categories and tags: CRUD + drag reorder (saved via app-bar action).
class CategoryTagsManageScreen extends ConsumerStatefulWidget {
  const CategoryTagsManageScreen({super.key});

  @override
  ConsumerState<CategoryTagsManageScreen> createState() =>
      _CategoryTagsManageScreenState();
}

class _CategoryTagsManageScreenState
    extends ConsumerState<CategoryTagsManageScreen> {
  List<CategoryDto> _categories = const [];
  List<TagResponseDto> _tags = const [];
  List<String> _initialCategoryOrder = const [];
  List<String> _initialTagOrder = const [];

  bool _loading = true;
  bool _saving = false;
  bool _reorderingCategories = false;
  bool _reorderingTags = false;
  Object? _loadError;

  bool get _orderDirty {
    final categoryIds = _categories.map((c) => c.id).toList();
    final tagIds = _tags.map((t) => t.id).toList();
    return !_listEquals(categoryIds, _initialCategoryOrder) ||
        !_listEquals(tagIds, _initialTagOrder);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _syncOrderBaseline() {
    _initialCategoryOrder = _categories.map((c) => c.id).toList();
    _initialTagOrder = _tags.map((t) => t.id).toList();
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final err = error.error;
      if (err is ApiException && err.message.isNotEmpty) {
        return err.message;
      }
    }
    if (error is StateError) {
      final message = error.message.trim();
      if (message.isNotEmpty) return message;
    }
    return UiStrings.categoryTagPickerLoadFailed;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final categoriesFuture =
          ref.read(categoriesServiceProvider).getCategoryTree();
      final tagsFuture = ref.read(tagsServiceProvider).getTags();
      final categoriesResponse = await categoriesFuture;
      final tagsResponse = await tagsFuture;

      if (!categoriesResponse.isSuccess || !tagsResponse.isSuccess) {
        throw StateError(
          categoriesResponse.isSuccess
              ? tagsResponse.message
              : categoriesResponse.message,
        );
      }

      if (!mounted) return;
      setState(() {
        _categories =
            flattenCategoryTree(categoriesResponse.data ?? const []);
        _tags = List<TagResponseDto>.from(tagsResponse.data ?? const []);
        _syncOrderBaseline();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _saveOrder() async {
    if (_saving || _reorderingCategories || _reorderingTags) return;

    if (_orderDirty) {
      setState(() => _saving = true);
      try {
        final categoriesDirty = !_listEquals(
          _categories.map((c) => c.id).toList(),
          _initialCategoryOrder,
        );
        final tagsDirty = !_listEquals(
          _tags.map((t) => t.id).toList(),
          _initialTagOrder,
        );

        if (categoriesDirty) {
          final ok = await _persistCategoryOrder(
            List<CategoryDto>.from(_categories),
            showError: true,
          );
          if (!ok) return;
        }
        if (tagsDirty) {
          final ok = await _persistTagOrder(
            List<TagResponseDto>.from(_tags),
            showError: true,
          );
          if (!ok) return;
        }
        $message.success(message: UiStrings.reorderSaved);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    if (mounted) context.pop();
  }

  List<ReorderItem> _categoryReorderItems() {
    return _categories
        .map(
          (category) => ReorderItem(
            id: category.id,
            parentId: category.parentId,
          ),
        )
        .toList();
  }

  Future<bool> _persistCategoryOrder(
    List<CategoryDto> fallback, {
    bool showError = true,
  }) async {
    if (_reorderingCategories) return false;
    _reorderingCategories = true;
    try {
      final response = await ref
          .read(categoriesServiceProvider)
          .reorderCategories(_categoryReorderItems());
      if (!response.isSuccess) {
        if (mounted) setState(() => _categories = fallback);
        if (showError) {
          $message.error(
            message: response.message.isNotEmpty
                ? response.message
                : UiStrings.categoryTagPickerLoadFailed,
          );
        }
        return false;
      }
      if (!mounted) return true;
      final tree = response.data;
      if (tree != null && tree.isNotEmpty) {
        setState(() {
          _categories = flattenCategoryTree(tree);
          _initialCategoryOrder = _categories.map((c) => c.id).toList();
        });
      } else {
        // Backend may return success with an empty tree; keep optimistic order.
        setState(() {
          _initialCategoryOrder = _categories.map((c) => c.id).toList();
        });
      }
      return true;
    } on DioException catch (error) {
      if (mounted) setState(() => _categories = fallback);
      if (showError) $message.error(message: _errorMessage(error));
      return false;
    } catch (error) {
      if (mounted) setState(() => _categories = fallback);
      if (showError) $message.error(message: _errorMessage(error));
      return false;
    } finally {
      _reorderingCategories = false;
      if (mounted) setState(() {});
    }
  }

  Future<bool> _persistTagOrder(
    List<TagResponseDto> fallback, {
    bool showError = true,
  }) async {
    if (_reorderingTags) return false;
    _reorderingTags = true;
    try {
      final response = await ref.read(tagsServiceProvider).reorderTags(
            _tags.map((tag) => tag.id).toList(),
          );
      if (!response.isSuccess) {
        if (mounted) setState(() => _tags = fallback);
        if (showError) {
          $message.error(
            message: response.message.isNotEmpty
                ? response.message
                : UiStrings.categoryTagPickerLoadFailed,
          );
        }
        return false;
      }
      if (!mounted) return true;
      final tags = response.data;
      if (tags != null && tags.isNotEmpty) {
        setState(() {
          _tags = List<TagResponseDto>.from(tags);
          _initialTagOrder = _tags.map((t) => t.id).toList();
        });
      } else {
        // Backend may return success with an empty list; keep optimistic order.
        setState(() {
          _initialTagOrder = _tags.map((t) => t.id).toList();
        });
      }
      return true;
    } on DioException catch (error) {
      if (mounted) setState(() => _tags = fallback);
      if (showError) $message.error(message: _errorMessage(error));
      return false;
    } catch (error) {
      if (mounted) setState(() => _tags = fallback);
      if (showError) $message.error(message: _errorMessage(error));
      return false;
    } finally {
      _reorderingTags = false;
      if (mounted) setState(() {});
    }
  }

  Future<String?> _promptName({
    required String title,
    required String label,
    String? initial,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text(UiStrings.confirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _addCategory() async {
    final name = await _promptName(
      title: UiStrings.newCategoryTitle,
      label: UiStrings.categoryNameLabel,
    );
    if (name == null || name.isEmpty) return;

    try {
      final response = await ref
          .read(categoriesServiceProvider)
          .createCategory(CreateCategoryDto(name: name));
      if (!response.isSuccess || response.data == null) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.categoryTagPickerLoadFailed,
        );
        return;
      }
      await _load();
    } on DioException catch (error) {
      $message.error(message: _errorMessage(error));
    }
  }

  Future<void> _editCategory(CategoryDto category) async {
    final name = await _promptName(
      title: UiStrings.editCategoryTitle,
      label: UiStrings.categoryNameLabel,
      initial: category.name,
    );
    if (name == null || name.isEmpty || name == category.name) return;

    try {
      final response = await ref.read(categoriesServiceProvider).updateCategory(
            UpdateCategoryDto(id: category.id, name: name),
          );
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.categoryTagPickerLoadFailed,
        );
        return;
      }
      await _load();
    } on DioException catch (error) {
      $message.error(message: _errorMessage(error));
    }
  }

  Future<void> _deleteCategory(CategoryDto category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(UiStrings.deleteCategoryConfirmTitle),
          content: const Text(UiStrings.deleteCategoryConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(UiStrings.draftsDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      final response = await ref
          .read(categoriesServiceProvider)
          .deleteCategory(category.id);
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.categoryTagPickerLoadFailed,
        );
        return;
      }
      await _load();
    } on DioException catch (error) {
      $message.error(message: _errorMessage(error));
    }
  }

  Future<void> _addTag() async {
    final name = await _promptName(
      title: UiStrings.newTagTitle,
      label: UiStrings.tagNameLabel,
    );
    if (name == null || name.isEmpty) return;

    try {
      final response =
          await ref.read(tagsServiceProvider).createTag(name);
      if (!response.isSuccess || response.data == null) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.categoryTagPickerLoadFailed,
        );
        return;
      }
      await _load();
    } on DioException catch (error) {
      $message.error(message: _errorMessage(error));
    }
  }

  Future<void> _deleteTag(TagResponseDto tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(UiStrings.deleteTagConfirmTitle),
          content: const Text(UiStrings.deleteTagConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(UiStrings.draftsDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      final response = await ref.read(tagsServiceProvider).deleteTag(tag.id);
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.categoryTagPickerLoadFailed,
        );
        return;
      }
      await _load();
    } on DioException catch (error) {
      $message.error(message: _errorMessage(error));
    }
  }

  void _onReorderCategory(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || _reorderingCategories) return;

    final previous = List<CategoryDto>.from(_categories);
    final next = List<CategoryDto>.from(_categories);
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);

    setState(() => _categories = next);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_persistCategoryOrder(previous));
    });
  }

  void _onReorderTag(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || _reorderingTags) return;

    final previous = List<TagResponseDto>.from(_tags);
    final next = List<TagResponseDto>.from(_tags);
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);

    setState(() => _tags = next);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_persistTagOrder(previous));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: UiStrings.manageCategoriesTagsTitle,
        showBack: true,
        actions: [
          TextButton(
            onPressed: _loading ||
                    _saving ||
                    _reorderingCategories ||
                    _reorderingTags
                ? null
                : _saveOrder,
            child: Text(
              UiStrings.save,
              style: theme.textTheme.labelLarge?.copyWith(
                color: _loading ||
                        _saving ||
                        _reorderingCategories ||
                        _reorderingTags
                    ? scheme.onSurfaceVariant
                    : scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _ErrorBody(
                  message: _errorMessage(_loadError!),
                  onRetry: _load,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: UiStrings.categoriesSection,
                        count: _categories.length,
                      ),
                      const SizedBox(height: 8),
                      _ListCard(
                        child: Column(
                          children: [
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: _categories.length,
                              onReorderItem: _onReorderCategory,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return _CategoryRow(
                                  key: ValueKey(category.id),
                                  index: index,
                                  category: category,
                                  onEdit: () => _editCategory(category),
                                  onDelete: () => _deleteCategory(category),
                                );
                              },
                            ),
                            _AddRowButton(
                              label: UiStrings.addCategory,
                              onTap: _addCategory,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: UiStrings.tagsSection,
                        count: _tags.length,
                      ),
                      const SizedBox(height: 8),
                      _ListCard(
                        child: Column(
                          children: [
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: _tags.length,
                              onReorderItem: _onReorderTag,
                              itemBuilder: (context, index) {
                                final tag = _tags[index];
                                return _TagRow(
                                  key: ValueKey(tag.id),
                                  index: index,
                                  tag: tag,
                                  onDelete: () => _deleteTag(tag),
                                );
                              },
                            ),
                            _AddRowButton(
                              label: UiStrings.addTag,
                              onTap: _addTag,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          '$count ${UiStrings.itemCountSuffix}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    super.key,
    required this.index,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final CategoryDto category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = category.name.isNotEmpty
        ? String.fromCharCodes(category.name.runes.take(1))
        : '?';

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_indicator,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.categorySelected,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                initial,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.notesCount} ${UiStrings.notesCountSuffix}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: scheme.onSurfaceVariant),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    super.key,
    required this.index,
    required this.tag,
    required this.onDelete,
  });

  final int index;
  final TagResponseDto tag;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notesCount = tag.notesCount ?? 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_indicator,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tagSelected,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$notesCount ${UiStrings.notesCountSuffix}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRowButton extends StatelessWidget {
  const _AddRowButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(UiStrings.categoryTagPickerRetry),
            ),
          ],
        ),
      ),
    );
  }
}
