#!/usr/bin/env bash
# Verify build artifacts BEFORE they reach a store: the file must really be
# signed by OUR release key and must not have been altered since signing.
#
# CI already prints the certificate (step "Report APK signing certificate"),
# but printing is not verifying — nothing in the pipeline ever checks the
# signature, so a debug-signed or tampered artifact would ship silently.
#
# Usage: ci/verify-artifacts.sh <file.apk|file.aab> [more files...]
#
# Tooling: apksigner for APKs (Android SDK build-tools), jarsigner + keytool
# for AABs (JDK — apksigner cannot read a bundle), bundletool for bundle
# integrity. Missing tooling is a FAILURE, never a skip.
#
# Local run on a box with the Ubuntu packages but no Android SDK:
#   BUNDLETOOL_JAR=~/.local/share/bundletool.jar ./ci/verify-artifacts.sh app-release.aab
set -euo pipefail

CERT_SHA256="c85160f3903f30bd454a8fa9e038d7f7ee3ed1eea0077dc5cbb5c660d3f7ba64"
CERT_SHA1="df2c7e725a29a71b6f66faa6fa0478775b46f723"
CERT_DN="CN=Muslim Leveling, O=Muslim Leveling, C=ID"
BUNDLETOOL_VERSION="1.18.3"
BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "  ok — $*"; }

find_tool() {
    local name="$1"; shift
    local c
    if c="$(command -v "$name" 2>/dev/null)"; then printf '%s' "$c"; return 0; fi
    for c in "$@"; do
        [ -x "$c" ] && { printf '%s' "$c"; return 0; }
    done
    return 1
}

# apksigner tinggal di build-tools/<versi>/ dan versinya beda-beda antar runner,
# jadi cari yang paling baru alih-alih menulis versinya di sini.
find_apksigner() {
    local c root dir
    if c="$(command -v apksigner 2>/dev/null)"; then printf '%s' "$c"; return 0; fi
    for root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Android/Sdk"; do
        [ -n "$root" ] || continue
        dir="$(ls -d "$root"/build-tools/*/ 2>/dev/null | sort -V | tail -1)"
        [ -n "$dir" ] && [ -x "${dir}apksigner" ] && { printf '%s' "${dir}apksigner"; return 0; }
    done
    return 1
}

APKSIGNER="$(find_apksigner)" || fail "apksigner tidak ada (Android SDK build-tools)"
JARSIGNER="$(find_tool jarsigner)" || fail "jarsigner tidak ada (JDK)"
KEYTOOL="$(find_tool keytool)" || fail "keytool tidak ada (JDK)"

BUNDLETOOL_JAR="${BUNDLETOOL_JAR:-}"
# bundletool hanya perlu untuk bundle — jangan unduh 32 MB di job yang cuma
# memverifikasi APK.
NEEDS_BUNDLETOOL=0
for f in "$@"; do
    case "$f" in *.aab) NEEDS_BUNDLETOOL=1 ;; esac
done
if [ "$NEEDS_BUNDLETOOL" = 1 ] && [ -z "$BUNDLETOOL_JAR" ]; then
    BUNDLETOOL_JAR="${RUNNER_TEMP:-/tmp}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
    if [ ! -s "$BUNDLETOOL_JAR" ]; then
        echo "  downloading bundletool ${BUNDLETOOL_VERSION}"
        curl -fsSL -o "$BUNDLETOOL_JAR" "$BUNDLETOOL_URL" \
            || fail "gagal mengunduh bundletool"
    fi
fi
if [ "$NEEDS_BUNDLETOOL" = 1 ]; then
    [ -s "$BUNDLETOOL_JAR" ] || fail "bundletool jar tidak ada: $BUNDLETOOL_JAR"
fi

echo "== tooling =="
echo "  apksigner   : $APKSIGNER"
echo "  jarsigner   : $JARSIGNER"
echo "  keytool     : $KEYTOOL"
if [ "$NEEDS_BUNDLETOOL" = 1 ]; then
    echo "  bundletool  : $BUNDLETOOL_JAR ($(java -jar "$BUNDLETOOL_JAR" version | tail -1))"
fi
echo "  expected DN : $CERT_DN"
echo "  expected S-1: $CERT_SHA1"
echo "  expected S-256: $CERT_SHA256"

for FILE in "$@"; do
    [ -f "$FILE" ] || fail "artefak tidak ditemukan: $FILE"
    case "$FILE" in
        *.apk) KIND=apk ;;
        *.aab) KIND=aab ;;
        *) fail "jenis artefak tidak dikenal: $FILE" ;;
    esac

    echo
    echo "== ${KIND^^} $FILE ($(stat -c%s "$FILE") bytes) =="

    # 1. Certificate must be ours. APK = v2 signer; AAB = JAR (v1) signer.
    if [ "$KIND" = apk ]; then
        CERT_OUT="$("$APKSIGNER" verify --print-certs "$FILE" 2>&1)" \
            || { echo "$CERT_OUT" >&2; fail "$FILE: blok tanda tangan APK tidak valid"; }
        # Label signer berbeda antar versi apksigner — 0.9 (build-tools lama /
        # paket Ubuntu) mencetak "Signer #1 certificate DN: …", 37.0 (runner CI)
        # mencetak "V2 Signer: certificate DN: …". Buang prefiksnya dulu, jangan
        # menulis satu format saja di regex.
        # Pemisahnya juga berbeda: 37.0 menulis "V2 Signer: certificate DN:",
        # 0.9 menulis "Signer #1 certificate DN:" (tanpa titik dua setelah #1).
        CERT_NORM="$(printf '%s' "$CERT_OUT" \
            | sed -n 's/^\(V[0-9.]* \)\?Signer\( #[0-9]*\)\?[: ]*certificate //p')"
        [ -n "$CERT_NORM" ] || {
            printf '%s\n' "$CERT_OUT" >&2
            fail "$FILE: format keluaran apksigner tidak dikenal"
        }
        GOT_DN="$(printf '%s' "$CERT_NORM" | sed -n 's/^DN: //p' | head -1)"
        GOT_SHA256="$(printf '%s' "$CERT_NORM" | sed -n 's/^SHA-256 digest: //p' | head -1)"
        GOT_SHA1="$(printf '%s' "$CERT_NORM" | sed -n 's/^SHA-1 digest: //p' | head -1)"
        [ -n "$GOT_DN" ] && [ -n "$GOT_SHA256" ] && [ -n "$GOT_SHA1" ] \
            || { printf '%s\n' "$CERT_OUT" >&2; fail "$FILE: sertifikat tidak terbaca dari apksigner"; }
        SCHEME_SHOW="$("$APKSIGNER" verify --verbose "$FILE" 2>&1 \
            | sed -n 's/^Verified using \(v[0-9][0-9.]*\) scheme.*: true$/\1/p' | paste -sd, -)"
    else
        CERT_OUT="$("$KEYTOOL" -printcert -jarfile "$FILE" 2>&1)" \
            || { echo "$CERT_OUT" >&2; fail "$FILE: tidak bisa membaca sertifikat"; }
        GOT_DN="$(printf '%s' "$CERT_OUT" | sed -n 's/^Owner: //p' | head -1)"
        GOT_SHA256="$(printf '%s' "$CERT_OUT" | grep -i -m1 'SHA256:' | sed 's/.*SHA256: *//' | tr -d ': \r' | tr '[:upper:]' '[:lower:]')"
        GOT_SHA1="$(printf '%s' "$CERT_OUT" | grep -i -m1 'SHA1:' | sed 's/.*SHA1: *//' | tr -d ': \r' | tr '[:upper:]' '[:lower:]')"
        [ -n "$GOT_DN" ] && [ -n "$GOT_SHA256" ] || fail "$FILE: sertifikat tidak terbaca dari keytool"
        SCHEME_SHOW="v1 (JAR)"
    fi
    echo "  cert DN     : $GOT_DN"
    echo "  cert SHA-256: $GOT_SHA256"
    echo "  cert SHA-1  : $GOT_SHA1"
    echo "  scheme      : ${SCHEME_SHOW:-?}"
    [ "$GOT_DN" = "$CERT_DN" ] \
        || fail "$FILE: DN tidak cocok (expected '$CERT_DN', dapat '$GOT_DN')"
    [ "$GOT_SHA256" = "$CERT_SHA256" ] \
        || fail "$FILE: SHA-256 tidak cocok — bukan keystore rilis kita"
    [ "$GOT_SHA1" = "$CERT_SHA1" ] \
        || fail "$FILE: SHA-1 tidak cocok — bukan keystore rilis kita"
    pass "sertifikat = keystore rilis kita"

    # 2. Integrity: every signature must actually check out.
    if [ "$KIND" = apk ]; then
        "$APKSIGNER" verify "$FILE" >/dev/null 2>&1 \
            || fail "$FILE: signature APK tidak valid (file berubah setelah ditandatangani?)"
    else
        # NB: jangan `printf ... | grep -q` di sini — dengan `set -o pipefail`,
        # grep -q yang keluar lebih awal mengirim SIGPIPE ke printf dan
        # pipeline-nya dilaporkan gagal meski polanya ketemu.
        SIG_OUT="$("$JARSIGNER" -verify "$FILE" 2>&1)" || {
            printf '%s\n' "$SIG_OUT" >&2
            fail "$FILE: signature JAR tidak valid (file berubah setelah ditandatangani?)"
        }
        case "$SIG_OUT" in
            *"jar verified"*) : ;;
            *) printf '%s\n' "$SIG_OUT" >&2; fail "$FILE: jarsigner tidak melaporkan 'jar verified'" ;;
        esac
        # Buktikan tanda tangannya memang milik kita (bukan cuma ada tanda tangan):
        # -certs mencetak X.509 per entri.
        "$JARSIGNER" -verify -verbose -certs "$FILE" 2>&1 | grep -qF "$CERT_DN" \
            || fail "$FILE: tidak ada entri yang ditandatangani dengan $CERT_DN"
        pass "entri ditandatangani dengan sertifikat kita"
    fi
    pass "integritas tanda tangan utuh"

    # 3. A bundle must additionally be structurally valid.
    if [ "$KIND" = aab ]; then
        BUNDLE_OUT="$(java -jar "$BUNDLETOOL_JAR" validate --bundle="$FILE" 2>&1)" || {
            printf '%s\n' "$BUNDLE_OUT" | tail -20 >&2
            fail "$FILE: bundletool validate gagal"
        }
        pass "bundletool validate lolos"

        # 4. Store readiness: R8 harus benar-benar jalan, dan mapping-nya harus
        #    ikut terbawa. Sejak Feb 2027 Play menuntut >=25% obfuscation /
        #    optimization / shrinking untuk DEX >10 MB, dan Play membaca angkanya
        #    dari BUNDLE-METADATA. Mapping yang hilang = stack trace tak terbaca.
        python3 - "$FILE" <<'PY' || fail "$FILE: cek R8/deobfuscation gagal"
import json, sys, zipfile

z = zipfile.ZipFile(sys.argv[1])
try:
    r8 = json.loads(z.read('BUNDLE-METADATA/com.android.tools/r8.json'))
except KeyError:
    print('r8.json tidak ada di BUNDLE-METADATA — R8 tidak dijalankan?', file=sys.stderr)
    sys.exit(1)

st = r8.get('stats', {})
pairs = {
    'obfuscation': 'noObfuscationPercentage',
    'optimization': 'noOptimizationPercentage',
    'shrinking': 'noShrinkingPercentage',
}
missing = [v for v in pairs.values() if v not in st]
if missing:
    print(f'stats R8 tidak lengkap: {missing}', file=sys.stderr)
    sys.exit(1)

dex = sum(i.file_size for i in z.infolist() if i.filename.startswith('base/dex/'))
print(f"  R8 {r8.get('version')} | DEX {dex / 1e6:.2f} MB")
for label, key in pairs.items():
    print(f"  {label:12s}: {100 - float(st[key]):5.2f}%"
          f"  (Play: butuh >=25% untuk DEX >10 MB)")
if dex > 10_000_000:
    weak = [l for l, k in pairs.items() if 100 - float(st[k]) < 25]
    if weak:
        print(f'DEX {dex / 1e6:.2f} MB tapi {weak} di bawah 25% — Play akan menolak',
              file=sys.stderr)
        sys.exit(1)

try:
    m = z.getinfo('BUNDLE-METADATA/com.android.tools.build.obfuscation/proguard.map')
except KeyError:
    print('proguard.map tidak ada — stack trace tak bisa di-deobfuscate', file=sys.stderr)
    sys.exit(1)
if m.file_size < 1024:
    print(f'proguard.map cuma {m.file_size} bytes — kosong?', file=sys.stderr)
    sys.exit(1)
print(f"  proguard.map: {m.file_size} bytes")
PY
        pass "R8 jalan + mapping ikut terbawa"
    fi
done

echo
echo "lokasi bundle/APK ${*}: TERVERIFIKASI (signed with the release keystore, utuh)"
