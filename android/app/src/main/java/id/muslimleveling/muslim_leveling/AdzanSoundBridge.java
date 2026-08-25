package id.muslimleveling.muslim_leveling;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;
import java.io.File;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Jembatan suara adzan custom (unduhan on-demand): mengubah path file
 * jadi FileProvider content URI dan memberi izin baca ke sistem.
 *
 * Suara channel notifikasi dibaca oleh NotificationManagerService
 * (proses sistem, di luar app) saat notifikasi tampil. File private
 * app tidak bisa diakses sistem, jadi harus lewat content:// URI +
 * grantUriPermission ke package "android". Tanpa grant ini suara
 * channel gagal dibaca dan sistem diam-diam fallback ke suara default.
 */
public class AdzanSoundBridge implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "muslim_leveling/adzan_sound";
    private final Context context;

    public AdzanSoundBridge(Context context) {
        this.context = context;
    }

    public static void register(FlutterEngine engine, Context context) {
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(new AdzanSoundBridge(context));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (!"contentUri".equals(call.method)) {
            result.notImplemented();
            return;
        }

        String filePath = call.argument("filePath");
        if (filePath == null) {
            result.error("INVALID_ARG", "filePath is required", null);
            return;
        }

        try {
            Uri uri = androidx.core.content.FileProvider.getUriForFile(
                    context,
                    context.getPackageName() + ".fileprovider",
                    new File(filePath)
            );
            context.grantUriPermission(
                    "android", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            result.success(uri.toString());
        } catch (Exception e) {
            result.error("URI_FAILED", e.getMessage(), null);
        }
    }
}
