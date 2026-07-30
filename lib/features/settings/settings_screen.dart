import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/wechat_icon.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/theme_provider.dart';
import 'user_profile_provider.dart';

/// Settings tab: account card, note management, bindings, and appearance.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _unbindingWechat = false;

  bool get _isWide => MediaQuery.sizeOf(context).width >= 600;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountCard(context, profileAsync),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.noteManagementSection),
          _noteManagementRow(context),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.accountBinding),
          _bindingEmailRow(context, profileAsync),
          const SizedBox(height: 12),
          _bindingWechatRow(context, profileAsync),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.appearance),
          _themeModeTile(themeMode),
        ],
      ),
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: UiStrings.settings,
        showBack: false,
      ),
      body: _isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: content,
              ),
            )
          : content,
    );
  }

  String _displayName(UserProfileDto p) {
    final n = p.nickname?.trim();
    if (n != null && n.isNotEmpty) return n;
    final email = p.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return UiStrings.nicknameUnset;
  }

  String _initial(UserProfileDto p) {
    final name = _displayName(p);
    if (name.isEmpty || name == UiStrings.nicknameUnset) return '?';
    return String.fromCharCodes(name.runes.take(1));
  }

  String _emailLabel(UserProfileDto p) {
    final e = p.email?.trim();
    if (e != null && e.isNotEmpty) return e;
    return UiStrings.notBound;
  }

  Widget _avatar(UserProfileDto p, ColorScheme scheme, ThemeData theme) {
    final url = p.avatar?.trim();
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: scheme.primary.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.primary.withValues(alpha: 0.15),
      child: Text(
        _initial(p),
        style: theme.textTheme.titleLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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

  Widget _buildAccountCard(
    BuildContext context,
    AsyncValue<UserProfileDto> profileAsync,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return profileAsync.when(
      skipLoadingOnReload: true,
      data: (profile) => Material(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppConstants.routeSettingsAccount),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                _avatar(profile, scheme, theme),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(profile),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailLabel(profile),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  UiStrings.edit,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: const CircularProgressIndicator(),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.elevatedSurfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _errorMessage(error),
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _themeModeTile(ThemeMode themeMode) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UiStrings.themeMode,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        UiStrings.themeModeHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (mode) {
              if (mode == null) return;
              ref.read(themeModeProvider.notifier).set(mode);
            },
            child: Column(
              children: [
                for (final option in const [
                  (ThemeMode.light, UiStrings.themeModeLight),
                  (ThemeMode.dark, UiStrings.themeModeDark),
                  (ThemeMode.system, UiStrings.themeModeSystem),
                ])
                  RadioListTile<ThemeMode>(
                    value: option.$1,
                    title: Text(option.$2),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteManagementRow(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: AppColors.elevatedSurfaceOf(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppConstants.routeSettingsCategoriesTags),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UiStrings.manageCategoriesTags,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      UiStrings.manageCategoriesTagsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bindingEmailRow(
    BuildContext context,
    AsyncValue<UserProfileDto> profileAsync,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = profileAsync.asData?.value;
    final email = profile?.email?.trim();
    final hasEmail = email != null && email.isNotEmpty;
    final subtitle = hasEmail ? email : UiStrings.notBound;
    final trailing = hasEmail ? UiStrings.bound : UiStrings.notBound;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.email_outlined,
              size: 20,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UiStrings.emailLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bindingWechatRow(
    BuildContext context,
    AsyncValue<UserProfileDto> profileAsync,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wxBound = profileAsync.asData?.value.wxBound == true;

    return Material(
      color: AppColors.elevatedSurfaceOf(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppConstants.routeSettingsWechatBind),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wechat.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const WechatIcon(size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UiStrings.wechatLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wxBound ? UiStrings.bound : UiStrings.notBound,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (wxBound)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _unbindingWechat
                      ? null
                      : () => _confirmUnbindWechat(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: _unbindingWechat
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          )
                        : Text(
                            UiStrings.unbind,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmUnbindWechat(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(UiStrings.wechatUnbindConfirmTitle),
          content: const Text(UiStrings.wechatUnbindConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(UiStrings.unbind),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await _unbindWechat();
  }

  Future<void> _unbindWechat() async {
    if (_unbindingWechat) return;
    setState(() => _unbindingWechat = true);
    try {
      final response = await ref.read(userServiceProvider).unbindWechat();
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.profileLoadFailed,
        );
        return;
      }
      final unbindMessage = response.data?.message.trim();
      $message.success(
        message: (unbindMessage != null && unbindMessage.isNotEmpty)
            ? unbindMessage
            : (response.message.isNotEmpty
                ? response.message
                : UiStrings.wechatUnbindSuccess),
      );
      await ref.read(userProfileProvider.notifier).refresh();
    } on DioException catch (e) {
      final err = e.error;
      final msg = err is ApiException && err.message.isNotEmpty
          ? err.message
          : UiStrings.profileLoadFailed;
      $message.error(message: msg);
    } finally {
      if (mounted) setState(() => _unbindingWechat = false);
    }
  }
}
