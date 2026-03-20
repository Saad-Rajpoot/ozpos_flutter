# Local Package Overrides

This folder contains local overrides of published packages to resolve dependency conflicts.

## imin_printer

- **Source:** Cloned from https://github.com/iminsoftware/imin_printer
- **Modification:** `IminStraElectronicSDK_V1.2.jar` removed from `android/build.gradle` to avoid conflict with `imin_hardware_plugin`
- **See:** [../imin_docs/imin_conflict_resolution.md](../imin_docs/imin_conflict_resolution.md) for details

To update from upstream:
```bash
cd imin_printer
git pull origin master
# Re-apply the build.gradle change if needed
```
