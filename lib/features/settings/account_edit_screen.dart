import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_button.dart';
import '../../ui/theme/app_colors.dart';
import 'avatar_crop_screen.dart';
import 'user_profile_provider.dart';

/// Account profile editor: prefill from [userProfileProvider], local avatar
/// preview, then optional upload + [UserService.updateProfile] on save.
class AccountEditScreen extends ConsumerStatefulWidget {
  const AccountEditScreen({super.key});

  @override
  ConsumerState<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends ConsumerState<AccountEditScreen> {
  late final TextEditingController _nameController;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prefillOnce(UserProfileDto profile) {
    if (_prefilled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _prefilled) return;
      _nameController.text = profile.nickname?.trim() ?? '';
      setState(() => _prefilled = true);
    });
  }

  String _initial(UserProfileDto profile) {
    final nickname = profile.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return String.fromCharCodes(nickname.runes.take(1));
    }
    final email = profile.email?.trim();
    if (email != null && email.isNotEmpty) {
      return String.fromCharCodes(email.runes.take(1));
    }
    return '?';
  }

  String _emailLabel(UserProfileDto profile) {
    final email = profile.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return UiStrings.notBound;
  }

  String _errorMessage(Object error) {
    if (error is StateError) {
      final message = error.message.trim();
      if (message.isNotEmpty) return message;
    }
    final raw = error.toString().trim();
    if (raw.isNotEmpty) return raw;
    return UiStrings.profileLoadFailed;
  }

  Widget _avatarWidget(
    UserProfileDto profile,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    final picked = _pickedBytes;
    if (picked != null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: scheme.primary.withValues(alpha: 0.15),
        backgroundImage: MemoryImage(picked),
      );
    }
    final url = profile.avatar?.trim();
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: scheme.primary.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: 48,
      backgroundColor: scheme.primary.withValues(alpha: 0.15),
      child: Text(
        _initial(profile),
        style: theme.textTheme.headlineMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    // file_picker ^11: pickFiles is static on FilePicker (no .platform).
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      $message.error(message: UiStrings.profileLoadFailed);
      return;
    }

    final cropped = await openAvatarCrop(context, bytes);
    if (!mounted || cropped == null || cropped.isEmpty) return;

    setState(() {
      _pickedBytes = cropped;
      _pickedFilename = file.name.isNotEmpty ? file.name : 'avatar.jpg';
      if (!_pickedFilename!.toLowerCase().endsWith('.jpg') &&
          !_pickedFilename!.toLowerCase().endsWith('.jpeg')) {
        _pickedFilename = 'avatar.jpg';
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final nickname = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      String? avatarUrl;
      final bytes = _pickedBytes;
      if (bytes != null) {
        final upload = await ref.read(storageServiceProvider).uploadFile(
              bytes,
              filename: _pickedFilename ?? 'avatar.jpg',
              type: 'IMAGE',
            );
        if (!upload.isSuccess || upload.data == null) {
          $message.error(
            message: upload.message.isNotEmpty
                ? upload.message
                : UiStrings.profileLoadFailed,
          );
          return;
        }
        avatarUrl = upload.data!.url;
      }

      final response = await ref.read(userServiceProvider).updateProfile(
            UpdateProfileDto(
              nickname: nickname.isEmpty ? null : nickname,
              avatar: avatarUrl,
            ),
          );
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.profileLoadFailed,
        );
        return;
      }
      $message.success(
        message: response.message.isNotEmpty
            ? response.message
            : UiStrings.savedToast,
      );
      await ref.read(userProfileProvider.notifier).refresh();
      if (!mounted) return;
      context.pop();
    } on DioException catch (e) {
      final err = e.error;
      final msg = err is ApiException && err.message.isNotEmpty
          ? err.message
          : UiStrings.profileLoadFailed;
      $message.error(message: msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      skipLoadingOnReload: true,
      data: (profile) {
        _prefillOnce(profile);
        return _buildEditor(context, profile, theme, scheme);
      },
      loading: () => Scaffold(
        backgroundColor: scheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.accountEditTitle,
          showBack: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: scheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.accountEditTitle,
          showBack: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage(error),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.read(userProfileProvider.notifier).refresh();
                  },
                  child: const Text(UiStrings.profileRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    UserProfileDto profile,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: scheme.surface,
          appBar: CustomAppBar(
            title: UiStrings.accountEditTitle,
            showBack: true,
            actions: [
              TextButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  UiStrings.save,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _saving
                        ? scheme.onSurfaceVariant
                        : scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _saving ? null : _pickAvatar,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _avatarWidget(profile, scheme, theme),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          UiStrings.tapToEditAvatar,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      UiStrings.usernameLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    enabled: !_saving,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.elevatedSurfaceOf(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      UiStrings.boundEmailLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedSurfaceOf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _emailLabel(profile),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      UiStrings.boundEmailHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: UiStrings.saveChanges,
                    expanded: true,
                    disabled: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_saving)
          const Positioned.fill(
            child: ModalBarrier(
              dismissible: false,
              color: Color(0x33000000),
            ),
          ),
        if (_saving) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
