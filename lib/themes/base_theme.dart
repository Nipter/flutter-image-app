import "package:flutter/material.dart";

const String TEXT_THEME = "Ubuntu Condensed";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4285354891),
      surfaceTint: Color(4285354891),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4293843967),
      onPrimaryContainer: Color(4280749379),
      secondary: Color(4284832367),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4293713399),
      onSecondaryContainer: Color(4280293418),
      tertiary: Color(4286599513),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294957534),
      onTertiaryContainer: Color(4281471000),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294965247),
      onSurface: Color(4280097312),
      onSurfaceVariant: Color(4283057486),
      outline: Color(4286281087),
      outlineVariant: Color(4291609807),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281544501),
      inversePrimary: Color(4292393722),
      primaryFixed: Color(4293843967),
      onPrimaryFixed: Color(4280749379),
      primaryFixedDim: Color(4292393722),
      onPrimaryFixedVariant: Color(4283710322),
      secondaryFixed: Color(4293713399),
      onSecondaryFixed: Color(4280293418),
      secondaryFixedDim: Color(4291805658),
      onSecondaryFixedVariant: Color(4283253591),
      tertiaryFixed: Color(4294957534),
      onTertiaryFixed: Color(4281471000),
      tertiaryFixedDim: Color(4294096832),
      onTertiaryFixedVariant: Color(4284824386),
      surfaceDim: Color(4292860128),
      surfaceBright: Color(4294965247),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294570489),
      surfaceContainer: Color(4294175731),
      surfaceContainerHigh: Color(4293781230),
      surfaceContainerHighest: Color(4293452008),
    );
  }

  ThemeData light() {
    return theme(
      lightScheme(),
    );
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4283447150),
      surfaceTint: Color(4285354891),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4286867875),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282990419),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4286345350),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4284495678),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288178031),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294965247),
      onSurface: Color(4280097312),
      onSurfaceVariant: Color(4282794314),
      outline: Color(4284702054),
      outlineVariant: Color(4286544002),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281544501),
      inversePrimary: Color(4292393722),
      primaryFixed: Color(4286867875),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4285157513),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4286345350),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4284635245),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4288178031),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4286402391),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292860128),
      surfaceBright: Color(4294965247),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294570489),
      surfaceContainer: Color(4294175731),
      surfaceContainerHigh: Color(4293781230),
      surfaceContainerHighest: Color(4293452008),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(
      lightMediumContrastScheme(),
    );
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281210186),
      surfaceTint: Color(4285354891),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283447150),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280753969),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282990419),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281997086),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284495678),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294965247),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280689194),
      outline: Color(4282794314),
      outlineVariant: Color(4282794314),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281544501),
      inversePrimary: Color(4294305791),
      primaryFixed: Color(4283447150),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281933910),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282990419),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4281477436),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284495678),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282851625),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292860128),
      surfaceBright: Color(4294965247),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294570489),
      surfaceContainer: Color(4294175731),
      surfaceContainerHigh: Color(4293781230),
      surfaceContainerHighest: Color(4293452008),
    );
  }

  ThemeData lightHighContrast() {
    return theme(
      lightHighContrastScheme(),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4292393722),
      surfaceTint: Color(4292393722),
      onPrimary: Color(4282197082),
      primaryContainer: Color(4283710322),
      onPrimaryContainer: Color(4293843967),
      secondary: Color(4291805658),
      onSecondary: Color(4281740608),
      secondaryContainer: Color(4283253591),
      onSecondaryContainer: Color(4293713399),
      tertiary: Color(4294096832),
      onTertiary: Color(4283114796),
      tertiaryContainer: Color(4284824386),
      onTertiaryContainer: Color(4294957534),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279570968),
      onSurface: Color(4293452008),
      onSurfaceVariant: Color(4291609807),
      outline: Color(4287991448),
      outlineVariant: Color(4283057486),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293452008),
      inversePrimary: Color(4285354891),
      primaryFixed: Color(4293843967),
      onPrimaryFixed: Color(4280749379),
      primaryFixedDim: Color(4292393722),
      onPrimaryFixedVariant: Color(4283710322),
      secondaryFixed: Color(4293713399),
      onSecondaryFixed: Color(4280293418),
      secondaryFixedDim: Color(4291805658),
      onSecondaryFixedVariant: Color(4283253591),
      tertiaryFixed: Color(4294957534),
      onTertiaryFixed: Color(4281471000),
      tertiaryFixedDim: Color(4294096832),
      onTertiaryFixedVariant: Color(4284824386),
      surfaceDim: Color(4279570968),
      surfaceBright: Color(4282136638),
      surfaceContainerLowest: Color(4279242002),
      surfaceContainerLow: Color(4280097312),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281084207),
      surfaceContainerHighest: Color(4281807673),
    );
  }

  ThemeData dark() {
    return theme(
      darkScheme(),
    );
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4292722431),
      surfaceTint: Color(4292393722),
      onPrimary: Color(4280354622),
      primaryContainer: Color(4288775617),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4292134622),
      onSecondary: Color(4279964452),
      secondaryContainer: Color(4288187555),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294425540),
      onTertiary: Color(4281076499),
      tertiaryContainer: Color(4290282379),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279570968),
      onSurface: Color(4294965756),
      onSurfaceVariant: Color(4291872979),
      outline: Color(4289241259),
      outlineVariant: Color(4287070603),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293452008),
      inversePrimary: Color(4283776115),
      primaryFixed: Color(4293843967),
      onPrimaryFixed: Color(4280025401),
      primaryFixedDim: Color(4292393722),
      onPrimaryFixedVariant: Color(4282591840),
      secondaryFixed: Color(4293713399),
      onSecondaryFixed: Color(4279569951),
      secondaryFixedDim: Color(4291805658),
      onSecondaryFixedVariant: Color(4282135110),
      tertiaryFixed: Color(4294957534),
      onTertiaryFixed: Color(4280616462),
      tertiaryFixedDim: Color(4294096832),
      onTertiaryFixedVariant: Color(4283574834),
      surfaceDim: Color(4279570968),
      surfaceBright: Color(4282136638),
      surfaceContainerLowest: Color(4279242002),
      surfaceContainerLow: Color(4280097312),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281084207),
      surfaceContainerHighest: Color(4281807673),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(
      darkMediumContrastScheme(),
    );
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294965756),
      surfaceTint: Color(4292393722),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4292722431),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965756),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4292134622),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965753),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294425540),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279570968),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294965756),
      outline: Color(4291872979),
      outlineVariant: Color(4291872979),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293452008),
      inversePrimary: Color(4281736787),
      primaryFixed: Color(4294042111),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4292722431),
      onPrimaryFixedVariant: Color(4280354622),
      secondaryFixed: Color(4293976571),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4292134622),
      onSecondaryFixedVariant: Color(4279964452),
      tertiaryFixed: Color(4294959075),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294425540),
      onTertiaryFixedVariant: Color(4281076499),
      surfaceDim: Color(4279570968),
      surfaceBright: Color(4282136638),
      surfaceContainerLowest: Color(4279242002),
      surfaceContainerLow: Color(4280097312),
      surfaceContainer: Color(4280426020),
      surfaceContainerHigh: Color(4281084207),
      surfaceContainerHighest: Color(4281807673),
    );
  }

  ThemeData darkHighContrast() {
    return theme(
      darkHighContrastScheme(),
    );
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
