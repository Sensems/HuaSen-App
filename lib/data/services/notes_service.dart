import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/note_dtos.dart';

/// Service for notes-related API calls.
///
/// All methods require JWT authentication (handled by [AuthInterceptor]).
class NotesService {
  NotesService(this._dio);

  final Dio _dio;

  /// List notes with optional filters.
  ///
  /// GET /notes
  ///
  /// Query `tags` is a repeated array (`tags[]`); single-tag `tag` was removed
  /// from OpenAPI. Each item may include joined `media` (no N+1).
  Future<ApiResponse<PaginatedNotesList>> listNotes({
    int? page,
    int? size,
    String? type,
    String? category,
    List<String>? tags,
    String? keyword,
    String? mediaType,
    NotesListView? view,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes',
      queryParameters: <String, dynamic>{
        'page': page,
        'size': size,
        'type': type,
        'category': category,
        'tags': (tags == null || tags.isEmpty) ? null : tags,
        'keyword': keyword,
        'mediaType': mediaType,
        'view': switch (view) {
          NotesListView.pinned => 'pinned',
          NotesListView.recent => 'recent',
          null => null,
        },
      }..removeWhere((_, v) => v == null),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) {
        final map = json as Map<String, dynamic>;
        final rawItems = map['items'] as List<dynamic>? ?? const [];
        final items = rawItems.map((raw) {
          final itemMap = raw as Map<String, dynamic>;
          final media = (itemMap['media'] as List?)
                  ?.map(
                    (e) =>
                        NoteMediaItemDto.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const <NoteMediaItemDto>[];
          return NotesListItem(
            note: NoteDetailDto.fromJson(itemMap),
            media: media,
          );
        }).toList();
        return PaginatedNotesList(
          items: items,
          total: (map['total'] as num).toInt(),
          page: (map['page'] as num).toInt(),
          size: (map['size'] as num).toInt(),
        );
      },
    );
  }

  /// Get note detail by ID.
  ///
  /// GET /notes/detail?id={id}
  ///
  /// Prefer [getNoteDetailBundle] when attachments are needed — detail already
  /// joins `media` (OpenAPI `MediaItemDto[]`); a separate `/notes/media` call
  /// is unnecessary for the editor.
  Future<ApiResponse<NoteDetailDto>> getNoteDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes/detail',
      queryParameters: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get note detail including joined `media` from the same response body.
  ///
  /// GET /notes/detail?id={id}
  Future<ApiResponse<NoteDetailBundle>> getNoteDetailBundle(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes/detail',
      queryParameters: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) {
        final map = json as Map<String, dynamic>;
        final media = (map['media'] as List<dynamic>?)
                ?.map(
                  (e) => NoteMediaItemDto.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const <NoteMediaItemDto>[];
        return NoteDetailBundle(
          note: NoteDetailDto.fromJson(map),
          media: media,
          categoryName: extractNoteCategoryName(map),
          tagNames: extractNoteTagNames(map),
        );
      },
    );
  }

  /// Create a new note.
  ///
  /// POST /notes/create
  Future<ApiResponse<NoteDetailDto>> createNote(CreateNoteDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/create',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update an existing note.
  ///
  /// POST /notes/update
  Future<ApiResponse<NoteDetailDto>> updateNote(UpdateNoteDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/update',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a note.
  ///
  /// POST /notes/delete
  Future<ApiResponse<NoteDetailDto>> deleteNote(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/delete',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Publish a note.
  ///
  /// POST /notes/publish
  Future<ApiResponse<NoteDetailDto>> publishNote(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/publish',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Archive a note.
  ///
  /// POST /notes/archive
  Future<ApiResponse<NoteDetailDto>> archiveNote(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/archive',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Toggle pin state for a note.
  ///
  /// POST /notes/pin
  Future<ApiResponse<NoteDetailDto>> pinNote(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/pin',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => NoteDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get media associated with a note.
  ///
  /// GET /notes/media?note_id={noteId}
  ///
  /// Response items are OpenAPI `MediaItemDto` (same shape as detail `media`).
  Future<ApiResponse<List<NoteMediaItemDto>>> getNoteMedia(String noteId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes/media',
      queryParameters: <String, dynamic>{'note_id': noteId},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => NoteMediaItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get share information for a note.
  ///
  /// GET /notes/share?id={id}
  Future<ApiResponse<ShareInfoDto>> getShareInfo(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes/share',
      queryParameters: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => ShareInfoDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
