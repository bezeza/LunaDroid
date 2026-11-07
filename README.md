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

## Visual direction

Classic Windows XP / Luna-era 3D illustration: dimensional objects, rich but balanced colors, soft shadows, highlights, gradients, and distinctive silhouettes. Avoid flat icons, generic square tiles, and inconsistent modern styles.

## Build

The source import is prepared with [scripts/import-from-termux.sh](scripts/import-from-termux.sh). In Termux, run:

```bash
curl -L https://raw.githubusercontent.com/bezeza/LunaDroid/main/scripts/import-from-termux.sh -o ~/import-lunadroid.sh
bash ~/import-lunadroid.sh
```

The script imports the Android source and PNGs, keeps the device-specific app map out of this public repository, and prepares safer local build behavior. It will request GitHub CLI authentication if needed. The complete APK build will be verified after import.

## License

No license has been selected yet. Until a license is added, the repository contents remain subject to applicable default copyright. Third-party trademarks and assets remain the property of their respective owners.
