cd flutter && flutter clean && flutter build apk --release &&
cp build/app/outputs/flutter-apk/app-release.apk ../vaani.apk  &&
cd .. &&
git add . &&
git commit -m "chore: release v0.1.0" &&
git tag v0.1.0 &&
git push && git push origin v0.1.0 &&
gh release create v0.1.0 vaani.apk --title "Vaani v0.1.0" --notes "Initial release" &&
rm vaani.apk &&
echo "[release] success"