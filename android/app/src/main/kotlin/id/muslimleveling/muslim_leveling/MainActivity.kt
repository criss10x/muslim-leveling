package id.muslimleveling.muslim_leveling

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    /** Penanda bahwa app dibuka dari tap widget, untuk dibaca Flutter. */
    private fun markIfQuestLink(source: Intent?) {
        if (source?.data?.host == "quests") {
            WidgetPrefs.of(this)
                .edit()
                .putBoolean(QUEST_LINK_KEY, true)
                .apply()
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        markIfQuestLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        markIfQuestLink(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ShareUtil.register(flutterEngine, this)
        AdzanSoundBridge.register(flutterEngine, this)

        // Widget hanya minta "gambar ulang". Semua isi widget sudah disiapkan
        // Dart; jalur ini tidak pernah menulis state permainan.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        QuestWidgetProvider.updateAll(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val WIDGET_CHANNEL = "ml/widget"

        /** Ditulis dengan prefix `flutter.` karena dibaca dari Dart. */
        val QUEST_LINK_KEY: String = WidgetPrefs.flutterKey("widget_open_quests")
    }
}
