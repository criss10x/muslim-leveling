import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/prayer_service.dart';
import '../theme/app_icons.dart';

typedef CityLoader = Future<List<String>?> Function(String province);

/// ponytail: shared city picker used by onboarding, jadwal, and profil.
/// Returns {id, name} or null if cancelled.
class CityPicker {
  static Future<({String id, String name})?> show(
    BuildContext context, {
    CityLoader? cityLoader,
  }) async {
    // l10n diambil di sini: builder dialog punya context sendiri, dan teks
    // dialog harus ikut bahasa aktif (dulu hardcode Indonesia walau app EN).
    final l10n = AppL10n.of(context);
    final ctrl = TextEditingController();
    final loadCities = cityLoader ?? PrayerService.citiesForProvince;
    List<String> cities = const [];
    String? selectedProvince;
    bool loading = false;
    // true = panggilan gagal (koneksi/timeout). Dibedakan dari daftar kosong:
    // yang satu soal koneksi, yang lain soal provinsi salah — pesannya tidak
    // boleh sama, karena menyarankan "coba provinsi lain" saat offline
    // mengirim user mencoba hal yang tidak akan pernah berhasil.
    bool failed = false;

    return showDialog<({String id, String name})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final pickingProvince = selectedProvince == null;
          final query = ctrl.text.trim().toLowerCase();
          final places = (pickingProvince ? PrayerService.provinces : cities)
              .where((name) => name.toLowerCase().contains(query))
              .toList();

          Future<void> pickProvince(String province) async {
            setState(() {
              selectedProvince = province;
              ctrl.clear();
              cities = const [];
              loading = false;
              failed = false;
            });
            setState(() => loading = true);
            final loaded = await loadCities(province);
            if (!ctx.mounted || selectedProvince != province) return;
            setState(() {
              cities = loaded ?? const [];
              loading = false;
              failed = loaded == null;
            });
          }

          void backToProvince() {
            setState(() {
              selectedProvince = null;
              ctrl.clear();
              cities = const [];
              loading = false;
              failed = false;
            });
          }

          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Row(
              children: [
                if (!pickingProvince)
                  IconButton(
                    icon: const Icon(AppIcons.arrowBack),
                    color: AppColors.primary,
                    onPressed: backToProvince,
                  ),
                Expanded(
                  child: Text(
                    pickingProvince
                        ? l10n.cityPickerTitleProv
                        : l10n.cityPickerTitleKab,
                    style: AppText.titleLg(),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!pickingProvince) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedProvince!,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    style: AppText.bodyLg(),
                    decoration: InputDecoration(
                      hintText: pickingProvince
                          ? l10n.cityPickerHintProv
                          : l10n.cityPickerHintKab,
                      hintStyle: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        AppIcons.search,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (loading)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else if (failed)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            l10n.cityPickerLoadFailed,
                            textAlign: TextAlign.center,
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Jalur pulang: tanpa ini satu paket hilang = user
                          // menutup dialog dan mengulang dari pemilihan provinsi.
                          TextButton(
                            onPressed: () => pickProvince(selectedProvince!),
                            child: Text(
                              l10n.cityPickerRetry,
                              style: AppText.bodyMd()
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (places.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        pickingProvince
                            ? l10n.cityPickerEmptyProv
                            : l10n.cityPickerEmptyKab,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: places.length,
                        itemBuilder: (_, i) {
                          final name = places[i];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              pickingProvince
                                  ? AppIcons.mapOutlined
                                  : AppIcons.locationOn,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            title: Text(name, style: AppText.bodyMd()),
                            onTap: () {
                              if (pickingProvince) {
                                pickProvince(name);
                                return;
                              }
                              Navigator.pop(ctx, (
                                id: '$selectedProvince/$name',
                                name: name,
                              ));
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.commonClose,
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
