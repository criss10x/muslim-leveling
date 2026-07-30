import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/prayer_service.dart';

typedef CityLoader = Future<List<String>> Function(String province);

/// ponytail: shared city picker used by onboarding, jadwal, and profil.
/// Returns {id, name} or null if cancelled.
class CityPicker {
  static Future<({String id, String name})?> show(
    BuildContext context, {
    CityLoader? cityLoader,
  }) async {
    final ctrl = TextEditingController();
    final loadCities = cityLoader ?? PrayerService.citiesForProvince;
    List<String> cities = const [];
    String? selectedProvince;
    bool loading = false;
    String? error;

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
              error = null;
            });
            setState(() => loading = true);
            final loaded = await loadCities(province);
            if (!ctx.mounted) return;
            setState(() {
              cities = loaded;
              loading = false;
              error = loaded.isEmpty
                  ? 'Kabupaten/kota tidak ditemukan. Coba pilih provinsi lain.'
                  : null;
            });
          }

          void backToProvince() {
            setState(() {
              selectedProvince = null;
              ctrl.clear();
              cities = const [];
              loading = false;
              error = null;
            });
          }

          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Row(
              children: [
                if (!pickingProvince)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.primary,
                    onPressed: backToProvince,
                  ),
                Expanded(
                  child: Text(
                    pickingProvince ? 'Pilih Provinsi' : 'Pilih Kabupaten/Kota',
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
                          ? 'Ketik nama provinsi...'
                          : 'Ketik nama kabupaten/kota...',
                      hintStyle: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
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
                  else if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        error!,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else if (places.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        pickingProvince
                            ? 'Provinsi tidak ditemukan'
                            : 'Kabupaten/kota tidak ditemukan',
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
                                  ? Icons.map_outlined
                                  : Icons.location_on,
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
                  'Tutup',
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
