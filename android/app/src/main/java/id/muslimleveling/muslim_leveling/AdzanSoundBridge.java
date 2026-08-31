package id.muslimleveling.muslim_leveling;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
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
 * grantUriPermission. Di beberapa vendor (terutama Xiaomi/ColorOS)
 * package "android" saja tidak cukup, jadi kita grant ke beberapa
 * package sistem sekaligus dan tambahkan FLAG_GRANT_PERSISTABLE_URI_PERMISSION
 * agar izin bertahan reboot untuk channel sound.
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
            final int mode = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION;

            // ponytail: target beberapa package sistem yang biasa memainkan
            // sound notifikasi. Grant ke "android" tidak selalu cukup.
            final String[] targets = {
                    "android",
                    "com.android.systemui",
                    "com.android.providers.media",
            };
            for (String pkg : targets) {
                try {
                    context.grantUriPermission(pkg, uri, mode);
                } catch (Exception ignored) {
                }
            }

            // Persist permission on Android 4.4+ supaya sound channel
            // tetap bisa diakses setelah reboot.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                try {
                    context.getContentResolver().takePersistableUriPermission(uri, mode);
                } catch (Exception ignored) {
                }
            }

            result.success(uri.toString());
        } catch (Exception e) {
            result.error("URI_FAILED", e.getMessage(), null);
        }
    }
}
