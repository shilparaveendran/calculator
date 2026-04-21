# Professional Calculator (GetX)

Production-ready Flutter calculator built with GetX architecture.

## Features

- Clean Controller/View separation with `GetxController`.
- Reactive UI using `obs` state and `Obx`.
- Decimal input support with validation (prevents invalid chained decimals).
- Chained operations with operator precedence support.
- Precision selector (2, 4, 6) persisted using `shared_preferences`.
- History persisted using `shared_preferences` and displayed via `Get.bottomSheet`.

> **Note:** The assignment mentions `GetStorage`; `get_storage` pulls `path_provider_android`, which does not compile on some older Flutter SDK + Android embedding combinations. This project uses `shared_preferences` for the same cross-session persistence without that dependency chain.
- Error feedback using `Get.snackbar`.
- Light/Dark theme toggle with persistent preference.
- Responsive layout with `LayoutBuilder`.

## Run

```bash
flutter pub get
flutter run
```

## Change Decimal Precision

1. Open the app.
2. Tap the tune icon in the app bar.
3. Select `2 decimals`, `4 decimals`, or `6 decimals`.
4. The selection is automatically saved and restored on next launch.
