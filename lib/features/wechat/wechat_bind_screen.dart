import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';
import '../settings/user_profile_provider.dart';

/// WeChat bind flow: paste binding code → [UserService.bindWechat].
class WechatBindScreen extends ConsumerStatefulWidget {
  const WechatBindScreen({super.key});

  @override
  ConsumerState<WechatBindScreen> createState() => _WechatBindScreenState();
}

class _WechatBindScreenState extends ConsumerState<WechatBindScreen> {
  late final TextEditingController _codeController;
  bool _binding = false;

  static const _steps = [
    UiStrings.wechatStep1,
    UiStrings.wechatStep2,
    UiStrings.wechatStep3,
    UiStrings.wechatStep4,
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      $message.error(message: UiStrings.wechatClipboardEmpty);
      return;
    }
    setState(() => _codeController.text = text);
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

  Future<void> _confirm() async {
    if (ref.read(userProfileProvider).asData?.value.wxBound == true) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      $message.error(message: UiStrings.wechatBindCodeRequired);
      return;
    }
    if (_binding) return;
    setState(() => _binding = true);
    try {
      final response = await ref.read(userServiceProvider).bindWechat(
            BindUserDto(bindingCode: code),
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
            : UiStrings.wechatBindSuccess,
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
      if (mounted) setState(() => _binding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.asData?.value;
    final profileReady = profile != null;
    final alreadyBound = profile?.wxBound == true;
    final canInteract = profileReady && !alreadyBound && !_binding;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const CustomAppBar(
        title: UiStrings.wechatBindTitle,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.wechat,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                UiStrings.wechatBindTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                UiStrings.wechatBindSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (profileAsync.isLoading && !profileReady) ...[
                const SizedBox(height: 20),
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              if (profileAsync.hasError && !profileReady) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _errorMessage(profileAsync.error!),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(userProfileProvider.notifier).refresh();
                      },
                      child: const Text(UiStrings.profileRetry),
                    ),
                  ],
                ),
              ],
              if (alreadyBound) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.wechat.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.wechat.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UiStrings.wechatAlreadyBound,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.wechat,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        UiStrings.wechatAlreadyBoundHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurfaceOf(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _codeController,
                      enabled: canInteract,
                      decoration: InputDecoration(
                        hintText: UiStrings.wechatBindCodeHint,
                        filled: true,
                        fillColor: scheme.surface,
                        suffixIcon: _codeController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: canInteract
                                    ? () => setState(
                                          () => _codeController.clear(),
                                        )
                                    : null,
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: canInteract ? _paste : null,
                            icon: const Icon(Icons.content_paste, size: 18),
                            label: const Text(UiStrings.wechatPaste),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: canInteract ? _confirm : null,
                            icon: _binding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.link, size: 18),
                            label: const Text(UiStrings.wechatConfirmBind),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.wechat,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.wechat.withValues(alpha: 0.4),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  UiStrings.wechatStepsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _steps.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.wechat,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _steps[i],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < _steps.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
