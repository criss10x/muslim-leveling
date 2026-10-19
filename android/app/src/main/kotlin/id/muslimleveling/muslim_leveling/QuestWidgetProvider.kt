package id.muslimleveling.muslim_leveling

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
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
 * Widget home screen: jam, sholat sekarang + berikutnya, dua quest teratas.
 *
 * PENTING: kelas ini TIDAK menghitung XP dan TIDAK menulis `game_state_v1`.
 * Semua teks sudah diterjemahkan Flutter dan datang lewat snapshot
 * `widget_snapshot_v1` (prefix `flutter.` ditambahkan SharedPreferences).
 * Satu-satunya penulis state permainan tetap `GameService._save()`.
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

        /** SharedPreferences Flutter menyimpan di `<packageName>_preferences`. */
        private const val PREFS_SUFFIX = "_preferences"

        /**
         * Nama kunci lengkap dengan prefix `flutter.` — SharedPreferences
         * menambahkan prefix itu pada semua kunci yang ditulis dari Dart.
         * Salah satu huruf saja di sini membuat widget selalu kosong.
         */
        private const val SNAPSHOT_KEY = "flutter.widget_snapshot_v1"

        private const val DEEP_LINK = "id.muslimleveling.muslim_leveling://quests"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, QuestWidgetProvider::class.java)
            )
            if (ids.isEmpty()) return
            ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
            scheduleNextBoundary(context)
        }

        private fun prefs(context: Context) =
            context.getSharedPreferences(
                context.packageName + PREFS_SUFFIX,
                Context.MODE_PRIVATE,
            )

        private fun todayKey(): String =
            SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

        private fun nowHhmm(): String =
            SimpleDateFormat("HH:mm", Locale.US).format(Date())

        /**
         * Teks fallback. Hanya dipakai saat snapshot belum ada (app belum pernah
         * dibuka). Tidak ada angka karangan: lebih baik kosong daripada sholat
         * yang salah.
         */
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

            val snap = prefs(context).getString(SNAPSHOT_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }
            if (snap == null) {
                views.setTextViewText(R.id.prayer_now, context.getString(R.string.widget_no_data))
                views.setTextViewText(R.id.prayer_next, "")
                views.setTextViewText(R.id.quest_now, context.getString(R.string.widget_open_once))
                views.setTextViewText(R.id.quest_status, "")
                views.setTextViewText(R.id.quest_next, "")
                return views
            }

            renderPrayers(context, views, snap)
            renderQuests(context, views, snap)
            return views
        }

        private fun renderPrayers(context: Context, views: RemoteViews, snap: JSONObject) {
            val days = snap.optJSONObject("days")
            val list = days?.optJSONArray(todayKey())

            // Snapshot bukan untuk hari ini: jangan tampilkan jam kemarin.
            // Jadwal sholat yang salah lebih buruk daripada ajakan membuka app.
            if (list == null || list.length() == 0) {
                views.setTextViewText(
                    R.id.prayer_now,
                    context.getString(R.string.widget_stale),
                )
                views.setTextViewText(R.id.prayer_next, "")
                return
            }

            val items = (0 until list.length()).mapNotNull { i ->
                val o = list.optJSONObject(i) ?: return@mapNotNull null
                Prayer(
                    key = o.optString("key"),
                    label = o.optString("label"),
                    time = o.optString("time"),
                )
            }
            if (items.isEmpty()) {
                views.setTextViewText(
                    R.id.prayer_now,
                    context.getString(R.string.widget_stale),
                )
                views.setTextViewText(R.id.prayer_next, "")
                return
            }

            val current = currentPrayer(items, nowHhmm())
            val next = nextPrayer(items, nowHhmm())

            views.setTextViewText(
                R.id.prayer_now,
                if (current == null) "—" else "${current.label} ${current.time}",
            )
            views.setTextViewText(
                R.id.prayer_next,
                if (next == null) "" else context.getString(R.string.widget_next, next.label, next.time),
            )
        }

        private fun renderQuests(context: Context, views: RemoteViews, snap: JSONObject) {
            val quests = snap.optJSONArray("quests")
            if (quests == null || quests.length() == 0) {
                views.setTextViewText(
                    R.id.quest_now,
                    context.getString(R.string.widget_all_done),
                )
                views.setTextViewText(R.id.quest_status, "")
                views.setTextViewText(R.id.quest_next, "")
                return
            }

            val first = quests.optJSONObject(0)
            if (first == null) {
                views.setTextViewText(R.id.quest_now, "")
                views.setTextViewText(R.id.quest_status, "")
            } else {
                views.setTextViewText(R.id.quest_now, questLine(first))
                views.setTextViewText(R.id.quest_status, questStatus(first))
            }

            val second = if (quests.length() > 1) quests.optJSONObject(1) else null
            views.setTextViewText(
                R.id.quest_next,
                if (second == null) "" else questLine(second),
            )
        }

        private fun questLine(q: JSONObject): String {
            val desc = q.optString("desc")
            val target = q.optInt("target", 1)
            val progress = q.optInt("progress", 0)
            return if (target > 1) "$desc  $progress/$target" else desc
        }

        /** Hanya label hadiah: widget tidak bisa dan tidak boleh claim. */
        private fun questStatus(q: JSONObject): String {
            val completed = q.optBoolean("completed")
            val claimed = q.optBoolean("claimed")
            return if (completed && !claimed) "+${q.optInt("xp")} XP" else ""
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
)
