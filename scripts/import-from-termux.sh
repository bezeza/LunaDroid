#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_URL="https://github.com/bezeza/LunaDroid.git"
REPO_DIR="$HOME/LunaDroid"
SOURCE_DIR="${1:-}"
ZIP_PATH="$HOME/storage/downloads/Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nПОМИЛКА: %s\n' "$*" >&2; exit 1; }

if ! command -v pkg >/dev/null 2>&1; then
  fail "Цей скрипт потрібно запускати в Termux на Android."
fi

if ! command -v git >/dev/null 2>&1; then
  say "Встановлюю git..."
  pkg install -y git
fi
if ! command -v gh >/dev/null 2>&1; then
  say "Встановлюю GitHub CLI..."
  pkg install -y gh
fi
if ! command -v unzip >/dev/null 2>&1; then
  say "Встановлюю unzip..."
  pkg install -y unzip
fi
if ! command -v python >/dev/null 2>&1; then
  say "Встановлюю Python..."
  pkg install -y python
fi

if ! gh auth status >/dev/null 2>&1; then
  say "Потрібно авторизувати GitHub. Введи код, який покаже gh, у браузері."
  gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git

if [ -z "$SOURCE_DIR" ]; then
  for candidate in \
    "$HOME/xp-iconpack-v3/Windows_XP_Classic_Clipart_Nova_IconPack" \
    "$HOME/Windows_XP_Classic_Clipart_Nova_IconPack"; do
    if [ -d "$candidate/app/src/main" ]; then
      SOURCE_DIR="$candidate"
      break
    fi
  done
fi

if [ -z "$SOURCE_DIR" ] || [ ! -d "$SOURCE_DIR/app/src/main" ]; then
  if [ -f "$ZIP_PATH" ]; then
    say "Розпаковую останній архів v3..."
    mkdir -p "$HOME/xp-iconpack-v3"
    unzip -oq "$ZIP_PATH" -d "$HOME/xp-iconpack-v3"
    SOURCE_DIR="$HOME/xp-iconpack-v3/Windows_XP_Classic_Clipart_Nova_IconPack"
  fi
fi

[ -d "$SOURCE_DIR/app/src/main" ] || fail "Не знайшов вихідну папку v3. Перевір, що ZIP лежить у Downloads як Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip, або передай шлях аргументом."

[ -f "$SOURCE_DIR/build.sh" ] || fail "У вихідній папці немає build.sh."
[ -f "$SOURCE_DIR/tools/generate_appfilter.py" ] || fail "У вихідній папці немає tools/generate_appfilter.py."
[ -f "$SOURCE_DIR/appfilter-map.tsv" ] || fail "У вихідній папці немає appfilter-map.tsv."

say "Клоную або оновлюю LunaDroid..."
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only origin main
else
  git clone "$REPO_URL" "$REPO_DIR"
fi

say "Копіюю Android source та 3D PNG assets..."
rm -rf "$REPO_DIR/app" "$REPO_DIR/tools"
cp -a "$SOURCE_DIR/app" "$REPO_DIR/app"
cp -a "$SOURCE_DIR/tools" "$REPO_DIR/tools"
cp "$SOURCE_DIR/build.sh" "$REPO_DIR/build.sh"
mkdir -p "$REPO_DIR/previews" "$REPO_DIR/docs"
[ ! -f "$SOURCE_DIR/preview_16_icons.jpg" ] || cp "$SOURCE_DIR/preview_16_icons.jpg" "$REPO_DIR/previews/"
[ ! -f "$SOURCE_DIR/preview_42_icons.jpg" ] || cp "$SOURCE_DIR/preview_42_icons.jpg" "$REPO_DIR/previews/"
[ ! -f "$SOURCE_DIR/README_UA.txt" ] || cp "$SOURCE_DIR/README_UA.txt" "$REPO_DIR/docs/UPSTREAM_README_UA.txt"

say "Зберігаю повну таблицю пакунків лише локально (вона не потрапить у public GitHub)..."
cp "$SOURCE_DIR/appfilter-map.tsv" "$REPO_DIR/appfilter-map.local.tsv"

say "Оновлюю генератор: зчитую публічну та локальну таблиці, не перезаписую tracked XML..."
python - "$REPO_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
gen = root / "tools/generate_appfilter.py"
text = gen.read_text(encoding="utf-8")

old_map = '''MAP_FILE = ROOT / "appfilter-map.tsv"
RES_XML = ROOT / "app/src/main/res/xml/appfilter.xml"
ASSET_XML = ROOT / "app/src/main/assets/appfilter.xml"

mapping = {}
with MAP_FILE.open(encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\\n")
        if not line or line.startswith("#"):
            continue
        parts = line.split("\\t")
        if len(parts) >= 2:
            mapping[parts[0].strip()] = parts[1].strip()
'''
new_map = '''MAP_FILES = (ROOT / "appfilter-map.tsv", ROOT / "appfilter-map.local.tsv")
GENERATED_XML = ROOT / "build" / "generated" / "appfilter.xml"

mapping = {}
for map_file in MAP_FILES:
    if not map_file.is_file():
        continue
    with map_file.open(encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\\n")
            if not line or line.startswith("#"):
                continue
            parts = line.split("\\t")
            if len(parts) >= 2:
                mapping[parts[0].strip()] = parts[1].strip()
'''
if old_map in text:
    text = text.replace(old_map, new_map, 1)
elif "MAP_FILES = (ROOT / \"appfilter-map.tsv\", ROOT / \"appfilter-map.local.tsv\")" not in text:
    raise SystemExit("Не вдалося безпечно оновити блок читання appfilter-map.tsv.")

old_write = '''RES_XML.write_text(xml, encoding="utf-8")
ASSET_XML.write_text(xml, encoding="utf-8")
'''
new_write = '''GENERATED_XML.parent.mkdir(parents=True, exist_ok=True)
GENERATED_XML.write_text(xml, encoding="utf-8")
'''
if old_write in text:
    text = text.replace(old_write, new_write, 1)
elif "GENERATED_XML.write_text(xml, encoding=\"utf-8\")" not in text:
    raise SystemExit("Не вдалося безпечно оновити місце запису appfilter.xml.")

gen.write_text(text, encoding="utf-8")

build = root / "build.sh"
b = build.read_text(encoding="utf-8")
old_build = '''echo "[3/6] Створюю прив'язки до програм, встановлених на телефоні..."
python "$ROOT/tools/generate_appfilter.py"

rm -rf "$BUILD/classes" "$BUILD/dex" "$BUILD/generated" "$BUILD/resources.zip"
mkdir -p "$BUILD/classes" "$BUILD/dex" "$BUILD/generated"
'''
new_build = '''echo "[3/6] Створюю прив'язки до програм, встановлених на телефоні..."
rm -rf "$BUILD/classes" "$BUILD/dex" "$BUILD/generated" "$BUILD/assets" "$BUILD/resources.zip"
mkdir -p "$BUILD/classes" "$BUILD/dex" "$BUILD/generated"
python "$ROOT/tools/generate_appfilter.py"
mkdir -p "$BUILD/assets"
cp -a "$APP/assets/." "$BUILD/assets/"
cp "$BUILD/generated/appfilter.xml" "$BUILD/assets/appfilter.xml"
'''
if old_build in b:
    b = b.replace(old_build, new_build, 1)
elif 'cp "$BUILD/generated/appfilter.xml" "$BUILD/assets/appfilter.xml"' not in b:
    raise SystemExit("Не вдалося безпечно оновити порядок генерації у build.sh.")

b = b.replace('-A "$APP/assets"', '-A "$BUILD/assets"', 1)

old_sign = '''apksigner sign \\
  --ks "$KEYSTORE" \\
  --ks-key-alias windowsxp \\
  --ks-pass pass:android \\
  --key-pass pass:android \\
  --out "$BUILD/Windows_XP_Classic_Clipart_Nova_IconPack.apk" \\
  "$INPUT_APK"
'''
new_sign = '''KEY_ALIAS="${KEY_ALIAS:-windowsxp}"
if [ -z "${KEYSTORE_PASSWORD:-}" ]; then
  read -rsp "Пароль keystore (не відображається): " KEYSTORE_PASSWORD
  echo
fi
if [ -z "${KEY_PASSWORD:-}" ]; then
  KEY_PASSWORD="$KEYSTORE_PASSWORD"
fi
export KEYSTORE_PASSWORD KEY_PASSWORD

apksigner sign \\
  --ks "$KEYSTORE" \\
  --ks-key-alias "$KEY_ALIAS" \\
  --ks-pass env:KEYSTORE_PASSWORD \\
  --key-pass env:KEY_PASSWORD \\
  --out "$BUILD/Windows_XP_Classic_Clipart_Nova_IconPack.apk" \\
  "$INPUT_APK"
'''
if old_sign in b:
    b = b.replace(old_sign, new_sign, 1)
elif '--ks-pass env:KEYSTORE_PASSWORD' not in b:
    raise SystemExit("Не вдалося безпечно прибрати hard-coded пароль підпису з build.sh.")

build.write_text(b, encoding="utf-8")
PY

say "Перевіряю XML та Python-синтаксис..."
python - "$REPO_DIR" <<'PY'
from pathlib import Path
import sys, xml.etree.ElementTree as ET, py_compile
root = Path(sys.argv[1])
for p in (root / "app/src/main").rglob("*.xml"):
    ET.parse(p)
py_compile.compile(str(root / "tools/generate_appfilter.py"), doraise=True)
print("XML і Python syntax: OK")
PY

cd "$REPO_DIR"
GH_LOGIN="$(gh api user --jq .login)"
GH_ID="$(gh api user --jq .id)"
git config user.name "$GH_LOGIN"
git config user.email "$GH_ID+$GH_LOGIN@users.noreply.github.com"

git add .gitignore app appfilter-map.tsv build.sh tools previews docs
git add -f scripts/import-from-termux.sh

if git diff --cached --quiet; then
  say "Немає нових змін для commit."
else
  git commit -m "Import Windows XP Classic Clipart v3 source"
fi

say "Надсилаю source до GitHub..."
git push origin main

say "ГОТОВО. Перевір репозиторій: https://github.com/bezeza/LunaDroid"
say "Повна device-specific таблиця лишилася локально у appfilter-map.local.tsv і не була додана до Git."
