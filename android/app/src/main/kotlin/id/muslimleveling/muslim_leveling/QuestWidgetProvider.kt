package id.muslimleveling.muslim_leveling

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Widget home screen: HUD sholat wajib hari ini.
 *
 * PENTING: kelas ini TIDAK menghitung XP dan TIDAK menulis `game_state_v1`.
 * Semua teks dan status sudah diputuskan Flutter dan datang lewat snapshot
 * `widget_snapshot_v1`. Satu-satunya penulis state permainan tetap
 * `GameService._save()`.
 *
 * Warna diambil dari DESIGN.md (Night Watch): jade = sudah dikerjakan, sian =
 * waktu yang sedang berjalan, emas = hadiah, redup = belum. Tidak ada warna
 * keempat; di sini emas tidak dipakai karena widget tidak pernah memberi hadiah.
 */
class QuestWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
        scheduleNextBoundary(context)
    }

    /** Dipanggil dari MainActivity saat Flutter meminta refresh. */
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) {
            updateAll(context)
        }
    }

    companion object {
        const val ACTION_REFRESH = "id.muslimleveling.muslim_leveling.WIDGET_REFRESH"

        private val SNAPSHOT_KEY: String = WidgetPrefs.flutterKey("widget_snapshot_v1")

        private const val DEEP_LINK = "id.muslimleveling.muslim_leveling://quests"

        /** Lima sel sholat, urut waktu; id resource-nya mengikuti urutan ini. */
        private val CELLS = listOf(
            Cell("subuh", R.id.name_subuh, R.id.time_subuh, R.id.bar_subuh),
            Cell("dzuhur", R.id.name_dzuhur, R.id.time_dzuhur, R.id.bar_dzuhur),
            Cell("ashar", R.id.name_ashar, R.id.time_ashar, R.id.bar_ashar),
            Cell("maghrib", R.id.name_maghrib, R.id.time_maghrib, R.id.bar_maghrib),
            Cell("isya", R.id.name_isya, R.id.time_isya, R.id.bar_isya),
        )

        // Tiga sinyal, tidak lebih. Lihat DESIGN.md "The Tiga Sinyal Rule".
        private const val JADE = "#34D399"      // sudah dikerjakan
        private const val TIME_NOW = "#00E1EF"  // waktu yang sedang berjalan
        private const val INK = "#DCEDE5"       // teks utama
        private const val MUTED = "#85948C"     // label redup
        private const val TRACK = "#4E5F57"     // rel kosong: 2.65:1 ke kartu (terbaca),\n                                                 // jade 3.53:1 di atasnya (status tetap jelas)

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, QuestWidgetProvider::class.java)
            )
            if (ids.isEmpty()) return
            ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
            scheduleNextBoundary(context)
        }

        private fun prefs(context: Context) = WidgetPrefs.of(context)

        private fun todayKey(): String =
            SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

        private fun nowHhmm(): String =
            SimpleDateFormat("HH:mm", Locale.US).format(Date())

        private fun buildViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.quest_widget)

            val openApp = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).apply {
                    data = Uri.parse(DEEP_LINK)
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, openApp)

            // Jam perangkat tanpa label terbaca sebagai jadwal. Beri nama
            // perannya, dan isi di ketiga state supaya header tidak berubah
            // bentuk saat data kosong atau basi.
            views.setTextViewText(
                R.id.clock_label,
                context.getString(R.string.widget_now),
            )

            val snap = prefs(context).getString(SNAPSHOT_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }
            if (snap == null) return emptyState(context, views)

            val list = snap.optJSONObject("days")?.optJSONArray(todayKey())
            if (list == null || list.length() == 0) {
                // Snapshot bukan untuk hari ini: jangan tampilkan jam kemarin.
                // Jadwal yang salah lebih buruk daripada ajakan membuka app.
                return staleState(context, views)
            }

            val items = (0 until list.length()).mapNotNull { i ->
                val o = list.optJSONObject(i) ?: return@mapNotNull null
                Prayer(
                    key = o.optString("key"),
                    label = o.optString("label"),
                    time = o.optString("time"),
                    done = o.optBoolean("done"),
                )
            }
            if (items.isEmpty()) return staleState(context, views)

            renderPrayers(context, views, items)
            return views
        }

        private fun renderPrayers(
            context: Context,
            views: RemoteViews,
            items: List<Prayer>,
        ) {
            val now = nowHhmm()
            val current = currentPrayer(items, now)
            val next = nextPrayer(items, now)

            views.setTextViewText(
                R.id.label_now,
                context.getString(R.string.widget_label).uppercase(Locale.US),
            )

            if (current == null) {
                views.setTextViewText(R.id.now_name, context.getString(R.string.widget_stale))
                views.setTextViewText(R.id.now_time, "")
                views.setTextColor(R.id.now_name, Color.parseColor(MUTED))
            } else {
                views.setTextViewText(R.id.now_name, current.label)
                views.setTextViewText(R.id.now_time, current.time)
                views.setTextColor(R.id.now_name, Color.parseColor(TIME_NOW))
            }

            views.setTextViewText(
                R.id.next,
                when {
                    next != null -> context.getString(
                        R.string.widget_next,
                        next.label,
                        next.time,
                    )
                    // Lewat Isya: berikutnya Subuh besok. Kalau semua sudah
                    // dikerjakan, itu kabar yang lebih layak ditampilkan.
                    items.all { it.done } -> context.getString(R.string.widget_all_done)
                    else -> context.getString(
                        R.string.widget_after,
                        items.first().label,
                        items.first().time,
                    )
                },
            )

            // Lima sel: nama, jam, dan bilah status. Bilah tetap pembawa status
            // utama; jam ikut diwarnai supaya sholat yang sedang berjalan
            // terhubung ke hero di atasnya (satu makna, satu warna).
            CELLS.forEachIndexed { i, cell ->
                val p = items.getOrNull(i)
                views.setTextViewText(cell.nameId, p?.label?.uppercase(Locale.US).orEmpty())
                views.setTextViewText(cell.timeId, p?.time.orEmpty())
                val barColor = when {
                    p == null -> TRACK
                    current != null && p.key == current.key -> TIME_NOW
                    p.done -> JADE
                    else -> TRACK
                }
                views.setInt(cell.barId, "setBackgroundColor", Color.parseColor(barColor))
                // Label kolom aktif ikut menyala. Tanpa ini kolom aktif terlihat
                // setengah aktif: jam dan bilah sian, namanya masih redup.
                views.setTextColor(
                    cell.nameId,
                    Color.parseColor(
                        if (p != null && current != null && p.key == current.key) {
                            TIME_NOW
                        } else {
                            MUTED
                        },
                    ),
                )
                views.setTextColor(
                    cell.timeId,
                    Color.parseColor(
                        when {
                            p == null -> MUTED
                            p.done -> JADE
                            current != null && p.key == current.key -> TIME_NOW
                            else -> INK
                        },
                    ),
                )
            }
        }

        private fun emptyState(context: Context, views: RemoteViews): RemoteViews {
            views.setTextViewText(R.id.label_now, "")
            views.setTextViewText(R.id.now_name, context.getString(R.string.widget_no_data))
            views.setTextViewText(R.id.now_time, "")
            views.setTextColor(R.id.now_name, Color.parseColor(MUTED))
            views.setTextViewText(R.id.next, "")
            CELLS.forEach { cell ->
                views.setTextViewText(cell.nameId, "")
                views.setTextViewText(cell.timeId, "")
                views.setInt(cell.barId, "setBackgroundColor", Color.parseColor(TRACK))
            }
            return views
        }

        private fun staleState(context: Context, views: RemoteViews): RemoteViews {
            views.setTextViewText(R.id.label_now, "")
            views.setTextViewText(R.id.now_name, context.getString(R.string.widget_stale))
            views.setTextViewText(R.id.now_time, "")
            views.setTextColor(R.id.now_name, Color.parseColor(MUTED))
            views.setTextViewText(R.id.next, "")
            return views
        }

        /**
         * Sholat wajib yang sedang berjalan.
         *
         * Cermin `GameService.currentPrayerInfo` untuk lima sholat wajib:
         * Subuh → Dzuhur → Ashar → Maghrib → Isya, dan Isya membungkus lewat
         * tengah malam (sebelum Subuh masih Isya). Dhuha tidak ikut.
         */
        internal fun currentPrayer(items: List<Prayer>, now: String): Prayer? {
            val nextIdx = items.indexOfFirst { it.time > now }
            return when {
                nextIdx < 0 -> items.lastOrNull()
                nextIdx == 0 -> items.last()
                else -> items[nextIdx - 1]
            }
        }

        /** Sholat wajib berikutnya; null kalau sudah lewat Isya (besok Subuh). */
        internal fun nextPrayer(items: List<Prayer>, now: String): Prayer? =
            items.firstOrNull { it.time > now }

        /**
         * Bangunkan widget tepat saat batas sholat berikutnya.
         *
         * `updatePeriodMillis` minimum 30 menit, jadi label bisa telat sampai
         * setengah jam. Alarm ini yang membuat pergantian sholat terasa pas.
         */
        private fun scheduleNextBoundary(context: Context) {
            val raw = prefs(context).getString(SNAPSHOT_KEY, null) ?: return
            val snap = runCatching { JSONObject(raw) }.getOrNull() ?: return
            val list = snap.optJSONObject("days")?.optJSONArray(todayKey()) ?: return

            val nowMs = System.currentTimeMillis()
            var best: Long? = null
            for (i in 0 until list.length()) {
                val time = list.optJSONObject(i)?.optString("time").orEmpty()
                val parts = time.split(":")
                if (parts.size != 2) continue
                val hour = parts[0].toIntOrNull() ?: continue
                val minute = parts[1].toIntOrNull() ?: continue
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                    set(Calendar.SECOND, 5)
                    set(Calendar.MILLISECOND, 0)
                }
                val at = cal.timeInMillis
                if (at > nowMs && (best == null || at < best)) best = at
            }
            val target = best ?: return

            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pi = PendingIntent.getBroadcast(
                context,
                0,
                Intent(context, QuestWidgetProvider::class.java).setAction(ACTION_REFRESH),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC, target, pi)
                } else {
                    am.setExact(AlarmManager.RTC, target, pi)
                }
            } catch (_: SecurityException) {
                // Izin exact alarm ditolak user: lain kali bisa telat beberapa
                // menit, tapi tetap diperbarui. Jauh lebih baik daripada beku.
                runCatching { am.set(AlarmManager.RTC, target, pi) }
            }
        }
    }
}

/** Satu sholat wajib, apa adanya dari snapshot. */
internal data class Prayer(
    val key: String,
    val label: String,
    val time: String,
    val done: Boolean,
)

/** Tiga id resource milik satu sel sholat. */
private data class Cell(
    val key: String,
    val nameId: Int,
    val timeId: Int,
    val barId: Int,
)
