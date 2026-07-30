import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/tag_response_dto.dart';
import '../../../ui/components/custom_button.dart';
import '../../../ui/theme/app_colors.dart';

/// Result from confirm/clear. Dismiss via X/barrier returns null instead.
class NotesFilterResult {
  const NotesFilterResult({
    this.categoryId,
    this.tagIds = const [],
  });

  final String? categoryId;
  final List<String> tagIds;
}

/// Prefetch categories/tags then show the select-only filter sheet.
Future<NotesFilterResult?> showNotesFilterSheet(
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
    final categoriesResponse = await categoriesService.getCategoryTree();
    final tagsResponse = await tagsService.getTags();

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

  return showModalBottomSheet<NotesFilterResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => NotesFilterSheet(
      initialCategoryId: initialCategoryId,
      initialTagIds: initialTagIds,
      initialCategories: categories,
      initialTags: tags,
    ),
  );
}

class NotesFilterSheet extends StatefulWidget {
  const NotesFilterSheet({
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
  State<NotesFilterSheet> createState() => _NotesFilterSheetState();
}

class _NotesFilterSheetState extends State<NotesFilterSheet> {
  late final List<CategoryDto> _categories;
  late final List<TagResponseDto> _tags;
  String? _selectedCategoryId;
  late List<String> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _categories = List<CategoryDto>.from(widget.initialCategories);
    _tags = List<TagResponseDto>.from(widget.initialTags);
    _selectedCategoryId = widget.initialCategoryId;
    _selectedTagIds = List<String>.from(widget.initialTagIds);
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

  void _popResult({String? categoryId, List<String> tagIds = const []}) {
    Navigator.of(context).pop(
      NotesFilterResult(categoryId: categoryId, tagIds: tagIds),
    );
  }

  void _onConfirm() {
    _popResult(
      categoryId: _selectedCategoryId,
      tagIds: List<String>.from(_selectedTagIds),
    );
  }

  void _onClear() {
    _popResult(categoryId: null, tagIds: const []);
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
                      UiStrings.notesCategoryTagFilterTitle,
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in _categories)
                        ChoiceChip(
                          label: Text(
                            category.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: UiStrings.notesCategoryTagFilterClear,
                      variant: CustomButtonVariant.secondary,
                      expanded: true,
                      compact: true,
                      onPressed: _onClear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: UiStrings.notesCategoryTagFilterConfirm,
                      expanded: true,
                      compact: true,
                      onPressed: _onConfirm,
                    ),
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
