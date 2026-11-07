# Source archive manifest

**Verified:** 2026-11-07  
**Repository:** https://github.com/bezeza/LunaDroid

This file records the exact source archives inspected for LunaDroid. It is a provenance and integrity manifest; it does **not** mean the ZIP binaries have been committed to this Git repository.

## Approved version policy

- **Primary development baseline:** Windows XP Classic Clipart v3.
- **Reserve/legacy version:** Windows XP Luna 3D v2 FIXED.
- Keep v2 separate from the v3 mainline. Do not use v2 as the new visual reference.

## Archive checksums

| Version | Archive | Size | SHA-256 |
|---|---|---:|---|
| Primary v3 | `Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip` | 7,646,501 bytes | `1652c2bf9c3b69b18a07de5b9ca019e090e23c6c34d4c75ce01486ce5176390a` |
| Reserve v2 | `Windows_XP_Luna_3D_Nova_IconPack_v2_FIXED.zip` | 9,887,548 bytes | `df0dc90deda0a79efa4459e3bd94987751d6a6fbe6d85cb8e8d7200a46afaa63` |

## Verified source inventory

| Check | v3 Classic Clipart | v2 Luna 3D FIXED |
|---|---:|---:|
| Files in extracted project folder | 58 | 58 |
| PNG files in `drawable-nodpi` | 43 | 43 |
| PNG dimensions / mode | 512×512 RGBA (all) | 512×512 RGBA (all) |
| Launcher drawable entries | 42 | 42 |
| Distinct PNG images including app icon | 26 | 42 |
| Distinct launcher images excluding app icon | 25 | 41 |
| Exact duplicate groups including app icon | 13 | 1 |
| Package rows in source app map | 771 | 771 |
| Android application package | `com.custom.windowsxp.novaicons` | `com.custom.windowsxp.novaicons` |
| Version code / name | 3 / `3.0 Classic XP` | 2 / `2.0 Luna 3D` |

## v3 import patch validation

The import script at `scripts/import-from-termux.sh` was tested against an isolated extraction of the exact v3 archive.

Verified:
- all three source transformation blocks matched and applied;
- `bash -n build.sh` passed after transformation;
- Python bytecode compilation for `tools/generate_appfilter.py` passed;
- all seven XML files parsed successfully;
- generated mapping output is redirected to `build/generated/appfilter.xml`;
- the build copies assets to `build/assets` and uses the generated appfilter without overwriting tracked source XML;
- hard-coded signing password arguments are replaced by environment variables or a hidden interactive prompt.

This is a static/import-script validation only. It is **not** a complete APK build, install test, or proof of full launcher mapping coverage.

## Important remaining limitations

1. The Android source tree and PNG assets are not yet present in the GitHub `main` branch.
2. The full 771-row device-specific app map must remain local; it can reveal installed applications. The public repository should keep only the minimal public mapping table.
3. The previous Termux log showed only six launcher components discovered and fallback mappings used. Full launcher activity discovery still needs testing on the actual phone.
4. A v3 APK build and install/upgrade test remain pending.
5. The v2 source archive is identified and checksum-verified here, but its full source tree has not yet been placed in a separate Git branch/tag.

## How to verify the archives locally

Run from a directory containing the two ZIP files:

```bash
sha256sum Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip
sha256sum Windows_XP_Luna_3D_Nova_IconPack_v2_FIXED.zip
```

The output should match the SHA-256 values above.
