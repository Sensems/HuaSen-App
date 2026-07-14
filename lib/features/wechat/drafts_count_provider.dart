import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';

class DraftsCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => _fetchTotal();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetchTotal);
  }

  Future<int> _fetchTotal() async {
    final response = await ref.read(notesServiceProvider).listNotes(
          type: 'draft',
          page: 1,
          size: 1,
        );
    final data = response.data;
    if (response.isSuccess && data != null) {
      return data.total;
    }
    throw StateError(
      response.message.isNotEmpty ? response.message : 'drafts count failed',
    );
  }
}

final draftsCountProvider =
    AsyncNotifierProvider<DraftsCountNotifier, int>(DraftsCountNotifier.new);
