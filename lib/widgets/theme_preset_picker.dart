import 'package:flutter/material.dart';

import '../services/theme_service.dart';
import '../theme/app_theme.dart';

Future<void> showThemePresetPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const ThemePresetPicker(),
  );
}

class ThemePresetPicker extends StatelessWidget {
  const ThemePresetPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tema aplikasi',
                  style: AppText.titleLg().copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                _PresetGroup(
                  label: 'Gelap',
                  presets: AppThemePreset.values
                      .where((preset) => !preset.isLight),
                ),
                const SizedBox(height: AppSpacing.md),
                _PresetGroup(
                  label: 'Terang',
                  presets: AppThemePreset.values
                      .where((preset) => preset.isLight),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PresetGroup extends StatelessWidget {
  const _PresetGroup({required this.label, required this.presets});

  final String label;
  final Iterable<AppThemePreset> presets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.labelCaps().copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final preset in presets) _PresetOption(preset: preset),
      ],
    );
  }
}

class _PresetOption extends StatelessWidget {
  const _PresetOption({required this.preset});

  final AppThemePreset preset;

  @override
  Widget build(BuildContext context) {
    final selected = themeNotifier.preset == preset;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () async {
            await themeNotifier.setPreset(preset);
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Semantics(
            selected: selected,
            button: true,
            label: preset.label,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        preset.label,
                        style: AppText.bodyLg().copyWith(
                          color: selected
                              ? AppColors.onPrimaryContainer
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        semanticLabel: 'Tema dipilih',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
