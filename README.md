# LunaDroid

**Windows XP Luna 3D Icon Pack for Android**

A nostalgic Windows XP-inspired 3D icon pack for Android, designed primarily for Nova Launcher. The goal is to bring the classic early-2000s desktop aesthetic to modern smartphones through individually illustrated, dimensional icons.

## Project status

- **Primary baseline:** v3 Classic Clipart (approved by the user).
- **Reserve version:** v2 Luna 3D; retained as a legacy backup, not as the new design direction.
- A local v2 APK build in Termux succeeded on 2026-11-07, including APK signature verification. The v3 APK build has not yet been verified.
- Full application coverage, icon consistency, and reproducible automated APK builds are still in progress.
- The v3 source archive has been audited; the safe Termux import script is ready. The v3 Android source tree and PNG assets still need to be pushed to main.

## Project documentation

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — full project brief, design rules, technical history, and handoff instructions for other AI assistants.
- [CHANGELOG.md](CHANGELOG.md) — development history and verified milestones.
- [ICON_CATALOG.csv](ICON_CATALOG.csv) — 42 icon assets, batch assignment, and duplicate-art status.
- [SOURCE_AUDIT.md](SOURCE_AUDIT.md) — comparison of v2 and v3 source archives, duplicate-image audit, and privacy/build findings.
- [SOURCE_ARCHIVE_MANIFEST.md](SOURCE_ARCHIVE_MANIFEST.md) — verified archive SHA-256 checksums, source inventory, and import validation.

## Visual direction

Classic Windows XP / Luna-era 3D illustration: dimensional objects, rich but balanced colors, soft shadows, highlights, gradients, and distinctive silhouettes. Avoid flat icons, generic square tiles, and inconsistent modern styles.

## Build

The combined import workflow is prepared with [scripts/import-all-versions-from-termux.sh](scripts/import-all-versions-from-termux.sh). Put the v3 archive in Android Downloads as Windows_XP_Classic_Clipart_Nova_IconPack_v3.zip. The previously extracted v2 source folder at ~/xp-iconpack-v2/Windows_XP_Luna_3D_Nova_IconPack is detected automatically; alternatively, put the FIXED v2 ZIP in Downloads.

In Termux, run one command:

```bash
curl -fsSL https://raw.githubusercontent.com/bezeza/LunaDroid/main/scripts/import-all-versions-from-termux.sh -o ~/import-lunadroid.sh && bash ~/import-lunadroid.sh
```

The workflow imports v3 into main, archives v2 in the separate v2-luna3d-reserve branch, keeps the full device-specific app map local and out of the public repository, and then starts the v3 APK build using the existing local signing keystore. It may request GitHub CLI authentication and the keystore password. The import scripts have been statically checked against the source archives; they have not yet been run on the user's phone.

## License

No license has been selected yet. Until a license is added, the repository contents remain subject to applicable default copyright. Third-party trademarks and assets remain the property of their respective owners.
