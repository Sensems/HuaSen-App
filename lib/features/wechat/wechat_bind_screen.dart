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
import '../../ui/components/wechat_icon.dart';
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

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyBoundCodeFromProfile();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyBoundCodeFromProfile() {
    if (!mounted) return;
    final profile = ref.read(userProfileProvider).asData?.value;
    if (profile?.wxBound != true) return;

    final code = profile!.bindingCode?.trim() ?? '';
    if (code.isEmpty || _codeController.text == code) return;

    setState(() => _codeController.text = code);
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
      final bindMessage = response.data?.message.trim();
      $message.success(
        message: (bindMessage != null && bindMessage.isNotEmpty)
            ? bindMessage
            : (response.message.isNotEmpty
                ? response.message
                : UiStrings.wechatBindSuccess),
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

    ref.listen(userProfileProvider, (previous, next) {
      _applyBoundCodeFromProfile();
    });

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
              _HeroSection(theme: theme, scheme: scheme),
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
              const SizedBox(height: 28),
              _InputCard(
                theme: theme,
                scheme: scheme,
                controller: _codeController,
                canInteract: canInteract,
                binding: _binding,
                onChanged: () => setState(() {}),
                onPaste: _paste,
                onConfirm: _confirm,
              ),
              const SizedBox(height: 28),
              _StepsSection(theme: theme, scheme: scheme),
              if (alreadyBound) ...[
                const SizedBox(height: 28),
                _BoundStatusCard(theme: theme, scheme: scheme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.theme,
    required this.scheme,
  });

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: _DashedRoundedRectPainter(
            color: AppColors.wechat.withValues(alpha: 0.45),
            radius: 20,
          ),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.wechat.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const WechatIcon(size: 50),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          UiStrings.wechatBindTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          UiStrings.wechatBindSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.theme,
    required this.scheme,
    required this.controller,
    required this.canInteract,
    required this.binding,
    required this.onChanged,
    required this.onPaste,
    required this.onConfirm,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final TextEditingController controller;
  final bool canInteract;
  final bool binding;
  final VoidCallback onChanged;
  final Future<void> Function() onPaste;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UiStrings.wechatBindCodeLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: canInteract,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: UiStrings.wechatBindCodeHint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppColors.wechatBindInputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      onPressed: canInteract
                          ? () {
                              controller.clear();
                              onChanged();
                            }
                          : null,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canInteract ? onPaste : null,
                  icon: Icon(
                    Icons.content_copy_outlined,
                    size: 18,
                    color: canInteract
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                  label: const Text(UiStrings.wechatPaste),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    backgroundColor: AppColors.elevatedSurfaceOf(context),
                    side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: canInteract ? onConfirm : null,
                  icon: binding
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({
    required this.theme,
    required this.scheme,
  });

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UiStrings.wechatStepsTitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _StepRow(
          index: 1,
          theme: theme,
          child: Text(
            UiStrings.wechatStep1,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _StepRow(
          index: 2,
          theme: theme,
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.45,
              ),
              children: const [
                TextSpan(text: UiStrings.wechatStep2Prefix),
                TextSpan(
                  text: UiStrings.wechatStep2Keyword,
                  style: TextStyle(
                    color: AppColors.wechat,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: UiStrings.wechatStep2Suffix),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _StepRow(
          index: 3,
          theme: theme,
          child: Text(
            UiStrings.wechatStep3,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _StepRow(
          index: 4,
          theme: theme,
          child: Text(
            UiStrings.wechatStep4,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.theme,
    required this.child,
  });

  final int index;
  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.wechat.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$index',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.wechat,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _BoundStatusCard extends StatelessWidget {
  const _BoundStatusCard({
    required this.theme,
    required this.scheme,
  });

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.wechat.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 20,
              color: AppColors.wechat,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UiStrings.wechatAlreadyBound,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  UiStrings.wechatAlreadyBoundHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;
  static const _strokeWidth = 1.5;
  static const _dashWidth = 5.0;
  static const _dashGap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _strokeWidth / 2,
        _strokeWidth / 2,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dashWidth + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}
