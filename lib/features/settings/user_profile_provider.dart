import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfileDto> {
  @override
  Future<UserProfileDto> build() => _fetch();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<UserProfileDto> _fetch() async {
    final response = await ref.read(userServiceProvider).getProfile();
    final data = response.data;
    if (response.isSuccess && data != null) {
      return data;
    }
    throw StateError(
      response.message.isNotEmpty ? response.message : 'profile load failed',
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileDto>(
  UserProfileNotifier.new,
);
