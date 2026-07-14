import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/theme_provider.dart';

/// Settings tab: account card, appearance, sync, thresholds, and bindings.
///
/// Dark mode is wired to [themeModeProvider] (session-only). Other controls
/// use local placeholder state.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _draftsSync = true;
  bool _clipboardSync = true;
  double _maxImageSizeMb = 10;
  double _maxFileSizeMb = 50;

  bool get _isWide => MediaQuery.sizeOf(context).width >= 600;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountCard(context),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.appearance),
          _settingsTile(
            icon: Icons.dark_mode_outlined,
            title: UiStrings.darkMode,
            subtitle: UiStrings.darkModeHint,
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).set(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.syncSection),
          _settingsTile(
            icon: Icons.inventory_2_outlined,
            title: UiStrings.draftsSync,
            subtitle: UiStrings.draftsSyncHint,
            trailing: Switch.adaptive(
              value: _draftsSync,
              onChanged: (v) => setState(() => _draftsSync = v),
            ),
          ),
          const SizedBox(height: 12),
          _settingsTile(
            icon: Icons.content_paste_go_outlined,
            title: UiStrings.clipboardSync,
            subtitle: UiStrings.clipboardSyncHint,
            trailing: Switch.adaptive(
              value: _clipboardSync,
              onChanged: (v) => setState(() => _clipboardSync = v),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.sizeThresholds),
          _settingsTile(
            icon: Icons.image_outlined,
            title: UiStrings.maxImageSize,
            subtitle: UiStrings.maxImageSizeHint,
            trailing: Text('${_maxImageSizeMb.round()} MB'),
            extra: Slider(
              value: _maxImageSizeMb,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_maxImageSizeMb.round()} MB',
              onChanged: (v) => setState(() => _maxImageSizeMb = v),
            ),
          ),
          const SizedBox(height: 12),
          _settingsTile(
            icon: Icons.insert_drive_file_outlined,
            title: UiStrings.maxFileSize,
            subtitle: UiStrings.maxFileSizeHint,
            trailing: Text('${_maxFileSizeMb.round()} MB'),
            extra: Slider(
              value: _maxFileSizeMb,
              min: 1,
              max: 200,
              divisions: 199,
              label: '${_maxFileSizeMb.round()} MB',
              onChanged: (v) => setState(() => _maxFileSizeMb = v),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.accountBinding),
          _bindingEmailRow(context),
          const SizedBox(height: 12),
          _bindingWechatRow(context),
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

  Widget _buildAccountCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: AppColors.lightSurface,
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
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                child: Text(
                  UiStrings.placeholderAvatarInitial,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UiStrings.placeholderDisplayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UiStrings.placeholderEmail,
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Widget? extra,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
              trailing,
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 8),
            extra,
          ],
        ],
      ),
    );
  }

  Widget _bindingEmailRow(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
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
                  UiStrings.placeholderEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            UiStrings.bound,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bindingWechatRow(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: AppColors.lightSurface,
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
                child: const Icon(
                  Icons.chat_bubble_outline,
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
                      UiStrings.wechatLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      UiStrings.bound,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  $message.success(message: UiStrings.unbindComingSoon);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
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
}
