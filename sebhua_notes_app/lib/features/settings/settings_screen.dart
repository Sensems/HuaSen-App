import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_bottom_nav.dart';

/// Screen for app settings.
///
/// Contains a dark-mode toggle, a clipboard-sync toggle, and size threshold
/// sliders for images and files. All controls are placeholders — state
/// management will be wired to providers in a later task.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _clipboardSync = false;
  double _maxImageSizeMb = 10;
  double _maxFileSizeMb = 50;

  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: UiStrings.settings,
        showBack: !_isWide,
      ),
      body: _buildBody(),
      bottomNavigationBar: _isWide
          ? null
          : CustomBottomNav(
              currentIndex: 3,
              items: const [
                CustomNavItem(
                  icon: Icons.note_outlined,
                  activeIcon: Icons.note,
                  label: UiStrings.navNotes,
                ),
                CustomNavItem(
                  icon: Icons.content_copy_outlined,
                  activeIcon: Icons.content_copy,
                  label: UiStrings.navClipboard,
                ),
                CustomNavItem(
                  icon: Icons.drafts_outlined,
                  activeIcon: Icons.drafts,
                  label: UiStrings.navDrafts,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: UiStrings.navSettings,
                ),
              ],
              onTap: _onNavTap,
            ),
    );
  }

  Widget _buildBody() {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(UiStrings.appearance),
          _buildDarkModeTile(),
          const SizedBox(height: 32),
          _buildSectionTitle(UiStrings.syncSection),
          _buildClipboardSyncTile(),
          const SizedBox(height: 32),
          _buildSectionTitle(UiStrings.sizeThresholds),
          _buildImageSizeSlider(),
          const SizedBox(height: 20),
          _buildFileSizeSlider(),
        ],
      ),
    );

    if (!_isWide) return content;

    // Desktop: center the content in a constrained width.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: content,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildDarkModeTile() {
    return _SettingsTile(
      icon: Icons.dark_mode_outlined,
      title: UiStrings.darkMode,
      subtitle: UiStrings.darkModeHint,
      trailing: Switch.adaptive(
        value: _darkMode,
        onChanged: (v) => setState(() => _darkMode = v),
      ),
    );
  }

  Widget _buildClipboardSyncTile() {
    return _SettingsTile(
      icon: Icons.sync,
      title: UiStrings.clipboardSync,
      subtitle: UiStrings.clipboardSyncHint,
      trailing: Switch.adaptive(
        value: _clipboardSync,
        onChanged: (v) => setState(() => _clipboardSync = v),
      ),
    );
  }

  Widget _buildImageSizeSlider() {
    final theme = Theme.of(context);
    return _SettingsTile(
      icon: Icons.image_outlined,
      title: UiStrings.maxImageSize,
      subtitle: UiStrings.maxImageSizeHint,
      trailing: Text(
        '${_maxImageSizeMb.round()} MB',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      extra: Slider(
        value: _maxImageSizeMb,
        min: 1,
        max: 50,
        divisions: 49,
        label: '${_maxImageSizeMb.round()} MB',
        onChanged: (v) => setState(() => _maxImageSizeMb = v),
      ),
    );
  }

  Widget _buildFileSizeSlider() {
    final theme = Theme.of(context);
    return _SettingsTile(
      icon: Icons.insert_drive_file_outlined,
      title: UiStrings.maxFileSize,
      subtitle: UiStrings.maxFileSizeHint,
      trailing: Text(
        '${_maxFileSizeMb.round()} MB',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      extra: Slider(
        value: _maxFileSizeMb,
        min: 1,
        max: 200,
        divisions: 199,
        label: '${_maxFileSizeMb.round()} MB',
        onChanged: (v) => setState(() => _maxFileSizeMb = v),
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/clipboard');
      case 2:
        context.go('/drafts');
    }
  }
}

/// A single settings row with icon, title, subtitle, and trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
            extra!,
          ],
        ],
      ),
    );
  }
}