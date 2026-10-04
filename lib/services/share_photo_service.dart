import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';

/// Background kartu share dari foto milik user.
///
/// SATU salinan saja di penyimpanan app, ditimpa tiap kali user memilih foto
/// baru. Ini disengaja: menyimpan path file galeri akan rusak begitu user
/// menghapus fotonya dari galeri, dan menyimpan banyak salinan akan menumpuk
/// tanpa batas.
///
/// Foto dikecilkan ke 1440px. Kartu share diekspor ~1020px (340dp x pixelRatio
/// 3.0), jadi 1440px sudah lebih dari cukup; tanpa batas ini satu foto kamera
/// bisa 8MB padahal yang terpakai seperempatnya.
class SharePhotoService {
  /// Nama tetap, bukan ber-timestamp: file lama ditimpa, bukan menumpuk.
  static const String fileName = 'share_bg_custom.jpg';

  /// Batas sisi terpanjang.
  static const double maxSide = 1440;

  /// Preset default yang dipakai kalau tidak ada foto user.
  static File? _cached;

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Foto yang tersimpan, atau null kalau belum ada. Tidak melempar: di widget
  /// test plugin path_provider tidak ada, dan sheet share harus tetap jalan
  /// dengan preset bawaan.
  static Future<File?> current() async {
    final c = _cached;
    if (c != null && c.existsSync()) return c;
    try {
      final f = await _file();
      if (!f.existsSync()) return null;
      _cached = f;
      return f;
    } catch (_) {
      return null;
    }
  }

  /// Ambil foto dari [source], simpan salinannya, kembalikan file-nya.
  ///
  /// null = user membatalkan. Kegagalan NYATA dilempar, bukan ditelan: kalau
  /// keduanya sama-sama null, user yang fotonya gagal diambil akan melihat
  /// layar diam tanpa tahu kenapa.
  static Future<File?> pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: 88,
    );
    if (picked == null) return null;

    // Salinan ditulis ke nama TETAP, jadi pakai nama sementara dulu: kalau
    // penulisan gagal di tengah, foto lama tidak ikut rusak atau hilang.
    final target = await _file();
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(await picked.readAsBytes(), flush: true);
    if (target.existsSync()) await target.delete();
    final saved = await tmp.rename(target.path);
    _cached = saved;
    return saved;
  }
}

/// Tanya sumber foto (kamera / galeri), lalu ambil fotonya.
///
/// Ditaruh di sini supaya share ayat Quran dan share Asmaul Husna tidak
/// menyalin alur yang sama — salinan kedua selalu menyimpang dari yang pertama.
Future<File?> pickSharePhoto(BuildContext context) async {
  final l10n = AppL10n.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.profilFromCamera),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.profilFromGallery),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return SharePhotoService.pick(source);
}
