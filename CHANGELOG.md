# Changelog

All notable project changes and verified milestones are recorded here.

## 2026-11-07 — Project documentation initialized

- Created the LunaDroid repository documentation baseline.
- Added the project brief, visual specification, seven-batch plan, known Android/Termux build history, and AI handoff protocol to PROJECT_CONTEXT.md.
- Added README.md with project purpose, status, documentation links, and licensing note.
- Added an initial icon/application inventory template in ICON_CATALOG.csv.
- Confirmed repository access through the connected GitHub integration.
- Confirmed the repository was empty before this documentation commit.
- Not yet done: import the actual Android source tree, verify current build files, audit PNG assets, complete launcher mappings, and configure GitHub Actions.
- Next step: import the existing Termux project into this repository and verify a clean APK build.

## 2026-11-07 — Source audit and Termux import preparation

- Located and inspected the v3 Classic Clipart source archive and the v2 FIXED archive in the user's Library.
- Selected v3 as the visual baseline because it follows the user's classic Windows XP 3D clipart reference more closely.
- Audited 43 PNG assets: v3 contains 26 unique images overall and 25 unique images among 42 launcher drawables; 17 launcher slots are exact duplicates across 12 groups.
- Compared v2: it has 42 unique images overall, but a different glossy-logo visual direction.
- Parsed the separate device inventory (779 package records) and compared it with the v3 mapping table (771 rows). Confirmed these are package counts, not launcher-activity counts.
- Added SOURCE_AUDIT.md, .gitignore, a minimal public appfilter-map.tsv, and scripts/import-from-termux.sh.
- The import script preserves the 771-row device-specific map locally as appfilter-map.local.tsv, patches the generator to merge local/public maps without committing private package inventory, generates appfilter.xml into build output, and removes hard-coded keystore password arguments.
- Verified original v3 shell script syntax, Python generator syntax, and parsing of all 7 XML files. Did not run a full APK build because Android SDK build tools/android.jar and the user's signing key are not available in this environment.
- Pending: user runs the import script in Termux to push the actual Java/XML/PNG source tree. Then verify launcher discovery and APK build on-device.

## 2026-11-07 — Version direction approved; v2 build verified on device

- User explicitly approved the version policy: v3 Classic Clipart is the primary design/source baseline; v2 Luna 3D is retained as a reserve/legacy version.
- Reconfirmed that v3 is the correct visual direction for future work. v2 must not silently replace the v3 art direction.
- Reviewed the user's latest Termux build log from ~/xp-iconpack-v2/Windows_XP_Luna_3D_Nova_IconPack: resource compilation and Java compilation completed, APK signing completed, and apksigner verified v1/v2/v3 signatures.
- The generated local APK was Downloads/Windows_XP_Luna_3D_Nova_IconPack.apk. This verifies the v2 local build only; no v3 build has yet been verified.
- The same log still reports only 6 launcher components discovered and fallback mappings used against a 771-row package map. Full launcher coverage remains unresolved.
- Updated PROJECT_CONTEXT.md with the approved version policy, build result, limitations, and next steps.
- v3 Android source import to main and a separate GitHub backup branch/tag for v2 source remain pending. No keystore, password, or private device app inventory was added to GitHub.
- Next: import v3 source into main, preserve v2 source in a separate archive branch/tag, then verify a clean v3 build and repair launcher discovery.
