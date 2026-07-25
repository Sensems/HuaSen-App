import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/create_category_dto.dart';
import '../../../data/models/tag_response_dto.dart';
import '../../../ui/components/custom_button.dart';
import '../../../ui/theme/app_colors.dart';

/// Result returned only when user taps「完成」. Closing via X / barrier returns null.
class CategoryTagPickerResult {
  const CategoryTagPickerResult({
    this.categoryId,
    this.categoryName,
    required this.tagIds,
    required this.tagNames,
  });

  final String? categoryId;
  final String? categoryName;
  final List<String> tagIds;
  final List<String> tagNames; // parallel to tagIds, same order
}

/// Shows the category/tag picker bottom sheet.
///
/// Prefetches categories/tags before opening so the sheet can size to its
/// content (no tall loading placeholder / jump). Scroll appears only when
/// content exceeds ~85% of the screen height.
///
/// Returns a [CategoryTagPickerResult] when the user taps「完成」; otherwise
/// `null` when dismissed via X or barrier (or if prefetch fails).
Future<CategoryTagPickerResult?> showCategoryTagPickerSheet(
  BuildContext context, {
  String? initialCategoryId,
  List<String> initialTagIds = const [],
}) async {
  final container = ProviderScope.containerOf(context);
  final categoriesService = container.read(categoriesServiceProvider);
  final tagsService = container.read(tagsServiceProvider);

  List<CategoryDto> categories;
  List<TagResponseDto> tags;
  try {
    final categoriesFuture = categoriesService.getCategoryTree();
    final tagsFuture = tagsService.getTags();
    final categoriesResponse = await categoriesFuture;
    final tagsResponse = await tagsFuture;

    if (!categoriesResponse.isSuccess || !tagsResponse.isSuccess) {
      final message = categoriesResponse.isSuccess
          ? tagsResponse.message
          : categoriesResponse.message;
      $message.error(
        message: message.isNotEmpty
            ? message
            : UiStrings.categoryTagPickerLoadFailed,
      );
      return null;
    }
    categories = categoriesResponse.data ?? const <CategoryDto>[];
    tags = tagsResponse.data ?? const <TagResponseDto>[];
  } on DioException catch (error) {
    final apiError = error.error;
    $message.error(
      message: apiError is ApiException && apiError.message.isNotEmpty
          ? apiError.message
          : UiStrings.categoryTagPickerLoadFailed,
    );
    return null;
  } on Object {
    $message.error(message: UiStrings.categoryTagPickerLoadFailed);
    return null;
  }

  if (!context.mounted) return null;

  return showModalBottomSheet<CategoryTagPickerResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => CategoryTagPickerSheet(
      initialCategoryId: initialCategoryId,
      initialTagIds: initialTagIds,
      initialCategories: categories,
      initialTags: tags,
    ),
  );
}

/// Bottom sheet content for selecting one category and multiple tags.
class CategoryTagPickerSheet extends ConsumerStatefulWidget {
  const CategoryTagPickerSheet({
    super.key,
    this.initialCategoryId,
    this.initialTagIds = const [],
    required this.initialCategories,
    required this.initialTags,
  });

  final String? initialCategoryId;
  final List<String> initialTagIds;
  final List<CategoryDto> initialCategories;
  final List<TagResponseDto> initialTags;

  @override
  ConsumerState<CategoryTagPickerSheet> createState() =>
      _CategoryTagPickerSheetState();
}

class _CategoryTagPickerSheetState
    extends ConsumerState<CategoryTagPickerSheet> {
  final _categoryNameController = TextEditingController();
  final _tagNameController = TextEditingController();

  late List<CategoryDto> _categories;
  late List<TagResponseDto> _tags;

  String? _selectedCategoryId;
  late List<String> _selectedTagIds;

  bool _creatingCategory = false;
  bool _creatingTag = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _selectedTagIds = List<String>.from(widget.initialTagIds);
    _categories = List<CategoryDto>.from(widget.initialCategories);
    _tags = List<TagResponseDto>.from(widget.initialTags);
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _tagNameController.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final err = error.error;
      if (err is ApiException && err.message.isNotEmpty) {
        return err.message;
      }
    }
    if (error is ApiException && error.message.isNotEmpty) {
      return error.message;
    }
    return UiStrings.categoryTagPickerLoadFailed;
  }

  void _toggleCategory(String id) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == id ? null : id;
    });
  }

  void _toggleTag(String id) {
    setState(() {
      if (_selectedTagIds.contains(id)) {
        _selectedTagIds = List<String>.from(_selectedTagIds)..remove(id);
      } else {
        _selectedTagIds = List<String>.from(_selectedTagIds)..add(id);
      }
    });
  }

  Future<void> _createCategory() async {
    if (_creatingCategory) return;
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) {
      $message.error(message: UiStrings.categoryTagPickerEmptyName);
      return;
    }

    setState(() => _creatingCategory = true);
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

      final created = response.data!;
      if (!mounted) return;
      setState(() {
        _categories = [..._categories, created];
        _selectedCategoryId = created.id;
        _categoryNameController.clear();
      });
    } on DioException catch (e) {
      $message.error(message: _errorMessage(e));
    } catch (e) {
      $message.error(message: _errorMessage(e));
    } finally {
      if (mounted) setState(() => _creatingCategory = false);
    }
  }

  Future<void> _createTag() async {
    if (_creatingTag) return;
    final name = _tagNameController.text.trim();
    if (name.isEmpty) {
      $message.error(message: UiStrings.categoryTagPickerEmptyName);
      return;
    }

    setState(() => _creatingTag = true);
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

      final created = response.data!;
      if (!mounted) return;
      setState(() {
        _tags = [..._tags, created];
        if (!_selectedTagIds.contains(created.id)) {
          _selectedTagIds = [..._selectedTagIds, created.id];
        }
        _tagNameController.clear();
      });
    } on DioException catch (e) {
      $message.error(message: _errorMessage(e));
    } catch (e) {
      $message.error(message: _errorMessage(e));
    } finally {
      if (mounted) setState(() => _creatingTag = false);
    }
  }

  void _onDone() {
    final categoryId = _selectedCategoryId;
    String? categoryName;
    if (categoryId != null) {
      for (final category in _categories) {
        if (category.id == categoryId) {
          categoryName = category.name;
          break;
        }
      }
    }

    final tagNamesById = {
      for (final tag in _tags) tag.id: tag.name,
    };
    final tagIds = List<String>.from(_selectedTagIds);
    final tagNames = [
      for (final id in tagIds) tagNamesById[id] ?? '',
    ];

    Navigator.of(context).pop(
      CategoryTagPickerResult(
        categoryId: categoryId,
        categoryName: categoryName,
        tagIds: tagIds,
        tagNames: tagNames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      UiStrings.categoryTagPickerTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),
            ),
            // Grow with content; scroll only when exceeding maxHeight.
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  Text(
                    UiStrings.categoryTagPickerSelectCategory,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height:10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in _categories)
                        ChoiceChip(
                          label: Text(
                            category.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black, // 修改字体颜色
                            ),
                          ),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => _toggleCategory(category.id),
                          showCheckmark: false,
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.categorySelected;
                            }
                            return null;
                          }),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _CreateRow(
                    controller: _categoryNameController,
                    hintText: UiStrings.categoryTagPickerNewCategoryHint,
                    busy: _creatingCategory,
                    onAdd: _createCategory,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    UiStrings.categoryTagPickerSelectTags,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _tags)
                        FilterChip(
                          label: Text(
                            tag.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          selected: _selectedTagIds.contains(tag.id),
                          onSelected: (_) => _toggleTag(tag.id),
                          showCheckmark: false,
                          // Material 3 ignores [selectedColor]; use [color].
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.tagSelected;
                            }
                            return null;
                          }),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _CreateRow(
                    controller: _tagNameController,
                    hintText: UiStrings.categoryTagPickerNewTagHint,
                    busy: _creatingTag,
                    onAdd: _createTag,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: CustomButton(
                label: UiStrings.categoryTagPickerDone,
                expanded: true,
                onPressed: _onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({
    required this.controller,
    required this.hintText,
    required this.busy,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hintText;
  final bool busy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final compactText = theme.textTheme.bodySmall;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !busy,
            style: compactText,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: compactText?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.elevatedSurfaceOf(context),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: scheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        FilledButton(
          onPressed: busy ? null : onAdd,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(52, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            textStyle: theme.textTheme.labelMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // 改这里的数字
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(UiStrings.categoryTagPickerAdd),
        ),
      ],
    );
  }
}

