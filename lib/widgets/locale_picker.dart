import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';

/// Picker bahasa. Pola sama dengan showThemePresetPicker — bottom sheet +
/// ListenableBuilder, tanpa state lokal.
Future<void> showLocalePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const LocalePicker(),
  );
}

class LocalePicker extends StatelessWidget {
  const LocalePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListenableBuilder(
      listenable: localeNotifier,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.localeTitle,
                  style: AppText.titleLg().copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                // null = ikut HP, itu sebabnya tipenya Locale? bukan Locale.
                LocaleOption(
                  value: null,
                  label: l10n.localeSystem,
                  current: localeNotifier.override,
                ),
                for (final locale in LocaleNotifier.supported)
                  LocaleOption(
                    value: locale,
                    label: locale.languageCode == 'id'
                        ? l10n.localeIndonesian
                        : l10n.localeEnglish,
                    current: localeNotifier.override,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Satu baris pilihan bahasa. Publik karena dipakai dua tempat: bottom sheet
/// Profil dan halaman pertama onboarding.
///
/// Tap = [localeNotifier.setLocale] + pop (kalau ada sheet). Di onboarding
/// tidak ada route di atasnya, jadi `canPop` false dan layarnya hanya
/// berganti bahasa — tidak perlu state tambahan.
class LocaleOption extends StatelessWidget {
  const LocaleOption({
    super.key,
    required this.value,
    required this.label,
    required this.current,
  });

  final Locale? value;
  final String label;
  final Locale? current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final selected = current == value;
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
            await localeNotifier.setLocale(value);
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Semantics(
            selected: selected,
            button: true,
            label: label,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: AppText.bodyLg().copyWith(
                          color: selected
                              ? AppColors.onPrimaryContainer
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        AppIcons.checkCircle,
                        color: AppColors.primary,
                        semanticLabel: l10n.localePicked,
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
