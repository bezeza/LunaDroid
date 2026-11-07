# LunaDroid source audit

**Audit date:** 2026-11-07  
**Selected baseline:** `Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip`  
**Comparison source:** `Windows_XP_Luna_3D_Nova_IconPack_v2_FIXED.zip`

## Archive comparison

| Check | Classic Clipart v3 | Luna 3D v2 FIXED |
|---|---:|---:|
| PNG files in drawable-nodpi | 43 | 43 |
| Launcher drawable entries in drawable.xml | 42 | 42 |
| Distinct PNG images across all 43 files | 26 | 42 |
| Distinct illustrations among the 42 launcher drawables | 25 | 41 |
| Exact duplicate groups | 13 | 1 |

The v3 preview and README explicitly describe a return to the soft, dimensional early-2000s Windows XP illustration style from the user's visual reference. Therefore v3 is the selected *style baseline*, even though its current assets contain more duplicate artwork than v2.

The v2 archive has more unique artwork, but its look is more like glossy beveled app logos. It should be retained as a historical reference only; do not silently replace the approved v3 art direction with v2.

## Exact duplicate artwork in v3

The following asset files are byte-identical within each group:

- `calculator.png` = `notes.png`
- `camera.png` = `gallery.png` = `instagram.png`
- `chatgpt.png` = `phone.png` = `whatsapp.png`
- `chrome.png` = `internet.png`
- `cinema.png` = `video.png` = `youtube.png`
- `clash_of_clans.png` = `games.png` = `play_store.png`
- `contacts.png` = `facebook.png`
- `filemanager.png` = `ic_pack.png`
- `gmail.png` = `mail.png`
- `gta_v.png` = `nfs.png`
- `messages.png` = `telegram.png`
- `minecraft.png` = `olx.png`
- `music.png` = `tiktok.png`

The `ic_pack.png` duplication is acceptable as an application launcher icon placeholder for now. The other duplicate groups mean several apps currently show identical pictures. These need individual artwork in the seven planned batches.

## Android project structure found in v3

- `app/src/main/AndroidManifest.xml`
- `app/src/main/java/com/custom/windowsxp/novaicons/ThemeActivity.java`
- `app/src/main/res/drawable-nodpi/*.png`
- `app/src/main/res/xml/appfilter.xml`
- `app/src/main/res/xml/drawable.xml`
- `app/src/main/res/values/strings.xml`
- `app/src/main/res/values/styles.xml`
- `app/src/main/assets/appfilter.xml`
- `app/src/main/assets/drawable.xml`
- `tools/generate_appfilter.py`
- `build.sh`
- `appfilter-map.tsv` (771 package rows in the source archive)
- `preview_16_icons.jpg`, `preview_42_icons.jpg`

## Mapping audit

The source archive's `appfilter-map.tsv` contains 771 package rows. The separate device inventory file `app-list (1).xml` contains 779 package records; all 771 map rows are present in that inventory, with eight inventory packages absent from the map.

These counts are **not** counts of launchable applications. The package inventory includes Android services, overlays, providers, and other packages without launcher activities.

The generator correctly intends to query Android for `MAIN` + `LAUNCHER` activities and match those package names against the map. However, the prior Termux build log showed only six fallback mappings after Android did not return the launcher list. This is the primary mapping defect to fix after source import.

## Privacy

The repository is public. The full 771-row mapping and raw 779-package device inventory are device-specific and can reveal the user's installed apps. Do not commit either file to the public repository.

The import workflow stores the full map locally as `appfilter-map.local.tsv`, which is excluded by `.gitignore`. The tracked `appfilter-map.tsv` contains only the small public baseline mapping list. The generator will be adjusted to merge both files locally.

## Build and signing risks

- The source `build.sh` is Termux-specific and is not directly suitable for GitHub Actions.
- The script expects Android build tools and an `android.jar`; earlier Termux logs showed package and SDK discovery issues.
- The source script signs with `~/.windows_xp_nova_iconpack.keystore` and contains hard-coded password arguments. Never commit the keystore or password. The import script replaces hard-coded password use with environment variables or an interactive prompt.
- Keep the same signing key if the user needs to update an already-installed APK. If the key is missing, do not silently generate a new one and claim it can update the installed package.

## Validation completed

- Both ZIP archives were extracted and inspected.
- PNG dimensions checked: all 43 assets in each archive are 512 × 512 RGBA.
- XML files parsed for structure during source review.
- Duplicate image groups calculated from SHA-256 hashes.
- The current Termux build was **not** run in this environment; a successful APK build is not claimed.

## Next actions

1. Import the v3 Android source into this repository from Termux.
2. Keep the full device map local and private.
3. Make the generator write to build output rather than overwriting tracked XML files.
4. Fix and verify launcher activity discovery on the actual phone.
5. Audit and replace duplicate artwork while preserving the v3 visual style.
6. Create a GitHub Actions build only after the source tree is imported and the custom build process is verified.
