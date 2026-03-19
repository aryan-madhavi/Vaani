# Release Process

## Versioning

Format: `MAJOR.MINOR.PATCH+BUILD` in `flutter/pubspec.yaml`

| Segment | When to increment |
|---------|------------------|
| `MAJOR` | Breaking changes / full reworks |
| `MINOR` | New features (e.g. new language, new screen) |
| `PATCH` | Bug fixes only |
| `+BUILD` | **Every release** — Android uses this as `versionCode` to detect upgrades. Must always go up. |

Examples: `0.1.0+1` → `0.1.1+2` (bug fix) → `0.2.0+3` (new feature)

---

## Steps for Every Release

### 1. Bump the version

Edit `flutter/pubspec.yaml`:
```yaml
version: 0.2.0+2   # increment MINOR/PATCH and always increment +BUILD
```

### 2. Build the release APK

```bash
cd flutter
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ../vaani.apk
cd ..
```

### 3. Commit and tag

```bash
git add flutter/pubspec.yaml
git commit -m "chore: release v0.2.0"
git tag v0.2.0
git push && git push origin v0.2.0
```

### 4. Create the GitHub release

```bash
gh release create v0.2.0 vaani.apk \
  --title "Vaani v0.2.0" \
  --notes "$(cat <<'EOF'
## What's new
- ...

## Bug fixes
- ...

## Download
Tap **vaani.apk** below to install directly on Android.
EOF
)"
```

The APK is always uploaded as `vaani.apk` so the invite link
`https://github.com/aryan-madhavi/Vaani/releases/latest/download/vaani.apk`
always points to the latest release without any code changes.

### 5. Clean up

```bash
rm vaani.apk
```

---

## Backend deployment (if backend changed)

```bash
cd backend
railway up
```

Or push to the connected branch — Railway redeploys automatically.

---

## Checklist

- [ ] `flutter/pubspec.yaml` version bumped (`MAJOR.MINOR.PATCH+BUILD`)
- [ ] `flutter build apk --release` succeeds
- [ ] APK tested on a physical device before publishing
- [ ] Git tag matches release version (`v0.2.0`)
- [ ] GitHub release created with `vaani.apk` asset
- [ ] Backend redeployed if `backend/` changed
