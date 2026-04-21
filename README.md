# Professional Calculator (GetX)

Production-ready Flutter calculator built with GetX architecture.

## Features

- Clean Controller/View separation with `GetxController`.
- Reactive UI using `obs` state and `Obx`.
- Decimal input support with validation (prevents invalid chained decimals).
- Chained operations with operator precedence support.
- Precision selector (`No precision`, 2, 4, 6) persisted using `GetStorage`.
- History persisted using `GetStorage` and displayed via `Get.bottomSheet`.
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
3. Select `No precision`, `2 decimals`, `4 decimals`, or `6 decimals`.
4. The selection is automatically saved and restored on next launch.
