import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_button.dart';
import '../../ui/theme/app_colors.dart';

/// UI-only account profile editor (no API).
class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: UiStrings.placeholderDisplayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    $message.success(message: UiStrings.savedToast);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: UiStrings.accountEditTitle,
        showBack: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              UiStrings.save,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
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
                onTap: () => $message.success(
                  message: UiStrings.avatarEditComingSoon,
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: scheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            UiStrings.placeholderAvatarInitial,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightSurface,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        UiStrings.placeholderEmail,
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
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
