import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/prayer_service.dart';
import '../theme/app_icons.dart';

typedef CityLoader = Future<List<String>?> Function(String province);

/// ponytail: shared city picker used by onboarding, jadwal, and profil.
/// Returns {id, name} or null if cancelled.
///
/// Langkah pertama = pilih wilayah (Indonesia / Luar Negeri). Indonesia
/// memakai alur provinsi→kabkota yang sudah ada; Luar Negeri mencari lewat
/// Nominatim dan mengembalikan koordinat (id = "lat,lon").
class CityPicker {
  static Future<({String id, String name, bool abroad})?> show(
    BuildContext context, {
    CityLoader? cityLoader,
  }) async {
    // l10n diambil di sini: builder dialog punya context sendiri, dan teks
    // dialog harus ikut bahasa aktif (dulu hardcode Indonesia walau app EN).
    final l10n = AppL10n.of(context);
    final ctrl = TextEditingController();
    final loadCities = cityLoader ?? PrayerService.citiesForProvince;
    List<String> cities = const [];
    List<({String id, String name})> abroadHits = const [];
    bool? abroad; // null = belum dipilih → tampilkan pemilih wilayah
    String? selectedProvince;
    bool loading = false;
    // true = panggilan gagal (koneksi/timeout). Dibedakan dari daftar kosong:
    // yang satu soal koneksi, yang lain soal provinsi salah — pesannya tidak
    // boleh sama, karena menyarankan "coba provinsi lain" saat offline
    // mengirim user mencoba hal yang tidak akan pernah berhasil.
    bool failed = false;

    return showDialog<({String id, String name, bool abroad})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final pickingRegion = abroad == null;
          final pickingProvince = abroad == false && selectedProvince == null;
          final query = ctrl.text.trim().toLowerCase();
          final places = abroad == true
              ? const <String>[]
              : (pickingProvince ? PrayerService.provinces : cities)
                    .where((name) => name.toLowerCase().contains(query))
                    .toList();

          void resetSearch() {
            ctrl.clear();
            cities = const [];
            abroadHits = const [];
            loading = false;
            failed = false;
          }

          Future<void> searchAbroad() async {
            setState(() {
              loading = true;
              failed = false;
            });
            final hits = await PrayerService.searchAbroadCities(ctrl.text);
            if (!ctx.mounted) return;
            setState(() {
              abroadHits = hits;
              loading = false;
            });
          }

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

          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Row(
              children: [
                if (!pickingRegion)
                  IconButton(
                    icon: const Icon(AppIcons.arrowBack),
                    color: AppColors.primary,
                    // Bertingkat: kabkota → provinsi dulu, baru provinsi →
                    // pemilih wilayah. Satu lompatan langsung ke wilayah
                    // memaksa user memilih Indonesia lagi hanya untuk
                    // berpindah kabupaten.
                    onPressed: () => setState(() {
                      if (selectedProvince != null && abroad == false) {
                        selectedProvince = null;
                      } else {
                        abroad = null;
                        selectedProvince = null;
                      }
                      resetSearch();
                    }),
                  ),
                Expanded(
                  child: Text(
                    pickingRegion
                        ? l10n.jdRegionTitle
                        : abroad == true
                        ? l10n.jdRegionAbroad
                        : pickingProvince
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
                  if (abroad == false && !pickingProvince) ...[
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
                  if (!pickingRegion)
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      textInputAction: abroad == true
                          ? TextInputAction.search
                          : TextInputAction.none,
                      style: AppText.bodyLg(),
                      decoration: InputDecoration(
                        hintText: abroad == true
                            ? l10n.jdAbroadSearchHint
                            : pickingProvince
                            ? l10n.cityPickerHintProv
                            : l10n.cityPickerHintKab,
                        hintStyle: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        suffixIcon: abroad == true
                            ? IconButton(
                                icon: const Icon(AppIcons.search),
                                onPressed: searchAbroad,
                              )
                            : null,
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
                      onSubmitted: abroad == true
                          ? (_) => searchAbroad()
                          : null,
                    ),
                  const SizedBox(height: 12),
                  if (loading)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else if (pickingRegion)
                    // Langkah pertama: pilih wilayah. Indonesia tetap satu-
                    // satunya jalur yang butuh pemilihan provinsi & kabkota.
                    ListView(
                      shrinkWrap: true,
                      children: [
                        _regionTile(
                          icon: AppIcons.locationOn,
                          label: l10n.jdRegionIndonesia,
                          onTap: () => setState(() {
                            abroad = false;
                            resetSearch();
                          }),
                        ),
                        _regionTile(
                          icon: AppIcons.mapOutlined,
                          label: l10n.jdRegionAbroad,
                          onTap: () => setState(() {
                            abroad = true;
                            resetSearch();
                          }),
                        ),
                      ],
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
                  else if (abroad == true)
                    // Hasil Nominatim. Kosong = nama tidak dikenali; pesannya
                    // menyarankan menulis dalam bahasa Inggris karena itulah
                    // yang paling sering menjadi sebabnya.
                    if (abroadHits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.jdAbroadEmpty,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: abroadHits.length,
                          itemBuilder: (_, i) {
                            final hit = abroadHits[i];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                AppIcons.locationOn,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              title: Text(hit.name, style: AppText.bodyMd()),
                              onTap: () => Navigator.pop(ctx, (
                                id: hit.id,
                                name: hit.name,
                                abroad: true,
                              )),
                            );
                          },
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
                                abroad: false,
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

  /// Baris pilihan wilayah (Indonesia / Luar Negeri) di langkah pertama.
  static Widget _regionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: AppText.bodyLg()),
      trailing: const Icon(AppIcons.arrowForward, size: 18),
      onTap: onTap,
    );
  }
}
