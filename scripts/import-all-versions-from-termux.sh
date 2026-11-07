#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_URL="https://github.com/bezeza/LunaDroid.git"
MAIN_DIR="$HOME/LunaDroid"
RESERVE_DIR="$HOME/LunaDroid-v2-reserve"
V3_ZIP="$HOME/storage/downloads/Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip"
V2_ZIP="$HOME/storage/downloads/Windows_XP_Luna_3D_Nova_IconPack_v2_FIXED.zip"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nПОМИЛКА: %s\n' "$*" >&2; exit 1; }

command -v pkg >/dev/null 2>&1 || fail "Запусти цей скрипт у Termux на Android."
command -v termux-setup-storage >/dev/null 2>&1 && termux-setup-storage >/dev/null 2>&1 || true

for p in git gh unzip python; do
  if ! command -v "$p" >/dev/null 2>&1; then pkg install -y "$p"; fi
done

if ! gh auth status >/dev/null 2>&1; then
  say "Авторизуй GitHub у браузері."
  gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git

V3_SOURCE=""
for candidate in \
  "$HOME/xp-iconpack-v3/Windows_XP_Classic_Clipart_Nova_IconPack" \
  "$HOME/Windows_XP_Classic_Clipart_Nova_IconPack"; do
  if [ -d "$candidate/app/src/main" ]; then V3_SOURCE="$candidate"; break; fi
done
if [ -z "$V3_SOURCE" ] && [ -f "$V3_ZIP" ]; then
  mkdir -p "$HOME/xp-iconpack-v3"
  unzip -oq "$V3_ZIP" -d "$HOME/xp-iconpack-v3"
  V3_SOURCE="$HOME/xp-iconpack-v3/Windows_XP_Classic_Clipart_Nova_IconPack"
fi
[ -d "$V3_SOURCE/app/src/main" ] || fail "Не знайшов v3. Завантаж Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip у Downloads або розпакуй його в ~/xp-iconpack-v3/."

say "Імпортую v3 Classic Clipart у main..."
if [ ! -d "$MAIN_DIR/.git" ]; then git clone "$REPO_URL" "$MAIN_DIR"; fi
bash "$MAIN_DIR/scripts/import-from-termux.sh" "$V3_SOURCE"


python - "$MAIN_DIR" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
readme = root / "README.md"
s = readme.read_text(encoding="utf-8")
s = s.replace(
    "The v3 Android source tree and PNG assets still need to be pushed to main.",
    "The v3 Android source tree and PNG assets are imported into main by the Termux import script. A clean v3 APK build and install test remain pending."
)
readme.write_text(s, encoding="utf-8")

manifest = root / "SOURCE_ARCHIVE_MANIFEST.md"
s = manifest.read_text(encoding="utf-8")
s = s.replace(
    "1. The Android source tree and PNG assets are not yet present in the GitHub main branch.",
    "1. The Android source tree and PNG assets are imported into GitHub main by the Termux import script; verify the pushed tree after the script completes."
)
manifest.write_text(s, encoding="utf-8")

context = root / "PROJECT_CONTEXT.md"
s = context.read_text(encoding="utf-8")
marker = "## 15. Імпорт вихідного коду v3 із Termux"
if marker not in s:
    s += "\n\n" + marker + "\n\n- Скрипт імпортував Android source tree та PNG-ресурси v3 Classic Clipart у гілку main.\n- Повна таблиця застосунків збережена локально як appfilter-map.local.tsv і не комітиться.\n- Цей етап підтверджує push вихідного коду, але не підтверджує повну збірку APK або встановлення v3.\n- Наступні кроки: перевірити дерево GitHub, зібрати v3 тим самим локальним keystore та перевірити launcher mappings на телефоні.\n"
context.write_text(s, encoding="utf-8")

changelog = root / "CHANGELOG.md"
s = changelog.read_text(encoding="utf-8")
marker = "## 2026-11-07 — v3 source imported to main"
if marker not in s:
    s += "\n\n" + marker + "\n\n- Imported the v3 Classic Clipart Android source tree and PNG assets into main from Termux.\n- Kept the full device-specific package map local and excluded it from the public repository.\n- v3 APK build and installation verification remain pending.\n"
changelog.write_text(s, encoding="utf-8")
PY
git -C "$MAIN_DIR" add README.md PROJECT_CONTEXT.md CHANGELOG.md SOURCE_ARCHIVE_MANIFEST.md
if ! git -C "$MAIN_DIR" diff --cached --quiet; then
  git -C "$MAIN_DIR" commit -m "docs: record v3 source import"
  git -C "$MAIN_DIR" push origin main
fi

V2_SOURCE=""
for candidate in \
  "$HOME/xp-iconpack-v2/Windows_XP_Luna_3D_Nova_IconPack" \
  "$HOME/Windows_XP_Luna_3D_Nova_IconPack"; do
  if [ -d "$candidate/app/src/main" ]; then V2_SOURCE="$candidate"; break; fi
done
if [ -z "$V2_SOURCE" ] && [ -f "$V2_ZIP" ]; then
  mkdir -p "$HOME/xp-iconpack-v2-reserve"
  unzip -oq "$V2_ZIP" -d "$HOME/xp-iconpack-v2-reserve"
  V2_SOURCE="$HOME/xp-iconpack-v2-reserve/Windows_XP_Luna_3D_Nova_IconPack"
fi
[ -d "$V2_SOURCE/app/src/main" ] || fail "v3 уже імпортовано. Не знайшов v2 source directory або FIXED ZIP для резервної гілки."
[ -f "$V2_SOURCE/tools/generate_appfilter.py" ] || fail "У v2 немає tools/generate_appfilter.py."

say "Готую окрему резервну гілку v2-luna3d-reserve..."
if [ ! -d "$RESERVE_DIR/.git" ]; then
  git clone "$REPO_URL" "$RESERVE_DIR"
fi
git -C "$RESERVE_DIR" fetch origin
if git -C "$RESERVE_DIR" ls-remote --exit-code --heads origin v2-luna3d-reserve >/dev/null 2>&1; then
  git -C "$RESERVE_DIR" checkout -B v2-luna3d-reserve origin/v2-luna3d-reserve
else
  git -C "$RESERVE_DIR" checkout -B v2-luna3d-reserve origin/main
fi

rm -rf "$RESERVE_DIR/app" "$RESERVE_DIR/tools" "$RESERVE_DIR/build.sh"
cp -a "$V2_SOURCE/app" "$RESERVE_DIR/app"
cp -a "$V2_SOURCE/tools" "$RESERVE_DIR/tools"
cp "$V2_SOURCE/build.sh" "$RESERVE_DIR/build.sh"
mkdir -p "$RESERVE_DIR/previews" "$RESERVE_DIR/docs"
[ ! -f "$V2_SOURCE/preview_16_icons.jpg" ] || cp "$V2_SOURCE/preview_16_icons.jpg" "$RESERVE_DIR/previews/"
[ ! -f "$V2_SOURCE/preview_42_icons.jpg" ] || cp "$V2_SOURCE/preview_42_icons.jpg" "$RESERVE_DIR/previews/"
[ ! -f "$V2_SOURCE/README_UA.txt" ] || cp "$V2_SOURCE/README_UA.txt" "$RESERVE_DIR/docs/UPSTREAM_README_UA.txt"

cp "$V2_SOURCE/appfilter-map.tsv" "$RESERVE_DIR/appfilter-map.local.tsv"
cp "$MAIN_DIR/appfilter-map.tsv" "$RESERVE_DIR/appfilter-map.tsv"

python - "$RESERVE_DIR/build.sh" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
s = s.replace(
    'apksigner sign \\\n  --ks "$KEYSTORE" \\\n  --ks-key-alias windowsxp \\\n  --ks-pass pass:android \\\n  --key-pass pass:android \\\n',
    'KEY_ALIAS="${KEY_ALIAS:-windowsxp}"\n'
    'if [ -z "${KEYSTORE_PASSWORD:-}" ]; then\n'
    '  read -rsp "Пароль keystore (не відображається): " KEYSTORE_PASSWORD\n'
    '  echo\n'
    'fi\n'
    'KEY_PASSWORD="${KEY_PASSWORD:-$KEYSTORE_PASSWORD}"\n'
    'export KEYSTORE_PASSWORD KEY_PASSWORD\n'
    'apksigner sign \\\n  --ks "$KEYSTORE" \\\n  --ks-key-alias "$KEY_ALIAS" \\\n  --ks-pass env:KEYSTORE_PASSWORD \\\n  --key-pass env:KEY_PASSWORD \\\n'
)
if '--ks-pass env:KEYSTORE_PASSWORD' not in s:
    raise SystemExit('Не вдалося безпечно замінити блок підпису v2 build.sh; файл не змінено.')
p.write_text(s, encoding="utf-8")
PY

cat > "$RESERVE_DIR/RESERVE_VERSION.md" <<'EOF'
# Windows XP Luna 3D v2 — reserve source

This branch preserves the v2 Luna 3D implementation separately from the v3 Classic Clipart mainline.

- Branch: v2-luna3d-reserve
- Android application ID: com.custom.windowsxp.novaicons
- Version code/name: 2 / 2.0 Luna 3D
- The user's local signing keystore is not included.
- The complete device-specific appfilter-map.tsv is kept locally as the ignored file appfilter-map.local.tsv; only the public minimal map is committed.
- The v2 source is retained for rollback/reference, not as the current visual direction.
EOF

cd "$RESERVE_DIR"
GH_LOGIN="$(gh api user --jq .login)"
GH_ID="$(gh api user --jq .id)"
git config user.name "$GH_LOGIN"
git config user.email "$GH_ID+$GH_LOGIN@users.noreply.github.com"
git add .gitignore app tools build.sh appfilter-map.tsv previews docs RESERVE_VERSION.md
if ! git diff --cached --quiet; then
  git commit -m "Archive Windows XP Luna 3D v2 source"
  git push -u origin v2-luna3d-reserve
else
  say "Резервна гілка v2 вже актуальна; нових змін немає."
fi

say "ГОТОВО: v3 імпортовано в main, v2 збережено окремо у v2-luna3d-reserve."
