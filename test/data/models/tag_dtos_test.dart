import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/data/models/tag_dtos.dart';

void main() {
  test('parses _count as number', () {
    final dto = TagResponseDto.fromJson({
      'id': 't1',
      'name': '随笔',
      'createdAt': '2026-07-03T10:00:00.000Z',
      '_count': 5,
    });
    expect(dto.notesCount, 5);
  });

  test('parses _count as prisma object', () {
    final dto = TagResponseDto.fromJson({
      'id': 't1',
      'name': '随笔',
      'createdAt': '2026-07-03T10:00:00.000Z',
      '_count': {'notes': 5},
    });
    expect(dto.notesCount, 5);
  });

  test('missing _count is null', () {
    final dto = TagResponseDto.fromJson({
      'id': 't1',
      'name': '随笔',
      'createdAt': '2026-07-03T10:00:00.000Z',
    });
    expect(dto.notesCount, isNull);
  });
}
