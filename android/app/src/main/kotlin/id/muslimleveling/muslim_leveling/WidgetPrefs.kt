package id.muslimleveling.muslim_leveling

import android.content.Context
import android.content.SharedPreferences

/**
 * Satu-satunya tempat nama file SharedPreferences ditulis.
 *
 * Plugin `shared_preferences_android` menyimpan ke file bernama
 * `FlutterSharedPreferences` — lihat konstanta `SHARED_PREFERENCES_NAME` di
 * LegacySharedPreferencesPlugin.java dan SharedPreferencesPlugin.kt. Nama
 * `<packageName>_preferences` TIDAK pernah dibuat oleh plugin itu.
 *
 * Salah nama di sini tidak melempar exception dan tidak menggagalkan build:
 * `getString` hanya mengembalikan null. Akibatnya widget selalu menampilkan
 * "buka app untuk mengaktifkan" dan tap widget tidak pernah membuka daftar
 * quest, walau app sudah dibuka berkali-kali.
 *
 * Jangan membaca/menulis SharedPreferences lewat nama lain di kode native.
 */
internal object WidgetPrefs {
    const val NAME = "FlutterSharedPreferences"

    fun of(context: Context): SharedPreferences =
        context.getSharedPreferences(NAME, Context.MODE_PRIVATE)

    /**
     * Kunci ditulis dari sisi native untuk dibaca Dart, jadi butuh prefix
     * `flutter.` yang selalu ditambahkan SharedPreferences versi Dart.
     */
    fun flutterKey(key: String): String = "flutter.$key"
}
