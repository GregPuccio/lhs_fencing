import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';

import 'theme_service.dart';

/// The ThemeController is used by many Widgets that users can interact with.
/// Widgets can read user theme settings, set user theme settings and listen
/// to user's theme changes.
///
/// The controller glues data Services to Flutter Widgets. The ThemeController
/// uses the ThemeService to save and load theme settings.
///
// ignore:prefer_mixin
class ThemeController with ChangeNotifier {
  ThemeController(this._themeService);

  // Make the ThemeService private so it cannot be used directly.
  final ThemeService _themeService;

  /// Load all ThemeController settings from the ThemeService. It may load from
  /// app defaults, a local database or the internet. The controller only knows
  /// it can load all the settings from the service.
  Future<void> loadAll() async {
    _themeMode = await _themeService.themeMode();
    _useSubThemes = await _themeService.useSubThemes();
    _useTextTheme = await _themeService.useTextTheme();
    _usedScheme = await _themeService.usedScheme();
    _schemeIndex = await _themeService.schemeIndex();
    _interactionEffects = await _themeService.interactionEffects();
    _useDefaultRadius = await _themeService.useDefaultRadius();
    _cornerRadius = await _themeService.cornerRadius();
    _inputDecoratorIsFilled = await _themeService.inputDecoratorIsFilled();
    _inputDecoratorBorderType = await _themeService.inputDecoratorBorderType();
    _inputDecoratorUnfocusedHasBorder =
        await _themeService.inputDecoratorUnfocusedHasBorder();
    _surfaceMode = await _themeService.surfaceMode();
    _blendLevel = await _themeService.blendLevel();
    _lightAppBarStyle = await _themeService.lightAppBarStyle();
    _darkAppBarStyle = await _themeService.darkAppBarStyle();
    _appBarOpacity = await _themeService.appBarOpacity();
    _appBarElevation = await _themeService.appBarElevation();
    _navBarStyle = await _themeService.navBarStyle();
    _useNavDivider = await _themeService.useNavDivider();
    _transparentStatusBar = await _themeService.transparentStatusBar();
    _tabBarStyle = await _themeService.tabBarStyle();
    _bottomNavigationBarOpacity =
        await _themeService.bottomNavigationBarOpacity();
    _bottomNavigationBarElevation =
        await _themeService.bottomNavigationBarElevation();
    _tooltipsMatchBackground = await _themeService.tooltipsMatchBackground();
    _swapLightColors = await _themeService.swapLightColors();
    _swapDarkColors = await _themeService.swapDarkColors();
    _lightIsWhite = await _themeService.lightIsWhite();
    _darkIsTrueBlack = await _themeService.darkIsTrueBlack();
    _useToDarkMethod = await _themeService.useToDarkMethod();
    _darkMethodLevel = await _themeService.darkMethodLevel();
    _useFlexColorScheme = await _themeService.useFlexColorScheme();
    _blendLightOnColors = await _themeService.blendLightOnColors();
    _blendDarkOnColors = await _themeService.blendDarkOnColors();
    _blendLightTextTheme = await _themeService.blendLightTextTheme();
    _blendDarkTextTheme = await _themeService.blendDarkTextTheme();
    _fabUseShape = await _themeService.fabUseShape();
    // Custom colors
    _primaryLight = await _themeService.primaryLight();
    _primaryContainerLight = await _themeService.primaryContainerLight();
    _secondaryLight = await _themeService.secondaryLight();
    _secondaryContainerLight = await _themeService.secondaryContainerLight();
    _primaryDark = await _themeService.primaryDark();
    _primaryContainerDark = await _themeService.primaryContainerDark();
    _secondaryDark = await _themeService.secondaryDark();
    _secondaryContainerDark = await _themeService.secondaryContainerDark();
    // Not using the ThemeService just a local toggle for platform, resets
    // to actual default platform when settings are loaded.
    _platform = defaultTargetPlatform;

    notifyListeners();
  }

  /// Reset all values to default values and save as current settings.
  ///
  /// Calls setters with notify = false, and calls notifyListeners once
  /// after all values have been reset and persisted.
  Future<void> resetAllToDefaults() async {
    await setThemeMode(ThemeService.defaultThemeMode, false);
    await setUseSubThemes(ThemeService.defaultUseSubThemes, false);
    await setUseTextTheme(ThemeService.defaultUseTextTheme, false);
    await setUsedScheme(ThemeService.defaultUsedScheme, false);
    await setSchemeIndex(ThemeService.defaultSchemeIndex, false);
    await setInteractionEffects(ThemeService.defaultInteractionEffects, false);
    await setUseDefaultRadius(ThemeService.defaultUseDefaultRadius, false);
    await setCornerRadius(ThemeService.defaultCornerRadius, false);
    await setInputDecoratorIsFilled(
        ThemeService.defaultInputDecoratorIsFilled, false);
    await setInputDecoratorBorderType(
        ThemeService.defaultInputDecoratorBorderType, false);
    await setInputDecoratorUnfocusedHasBorder(
        ThemeService.defaultInputDecoratorUnfocusedHasBorder, false);
    await setSurfaceMode(ThemeService.defaultSurfaceMode, false);
    await setBlendLevel(ThemeService.defaultBlendLevel, false);
    await setLightAppBarStyle(ThemeService.defaultLightAppBarStyle, false);
    await setDarkAppBarStyle(ThemeService.defaultDarkAppBarStyle, false);
    await setAppBarOpacity(ThemeService.defaultAppBarOpacity, false);
    await setAppBarElevation(ThemeService.defaultAppBarElevation, false);
    await setTransparentStatusBar(
        ThemeService.defaultTransparentStatusBar, false);
    await setTabBarStyle(ThemeService.defaultTabBarStyle, false);
    await setBottomNavigationBarOpacity(
        ThemeService.defaultBottomNavigationBarOpacity, false);
    await setBottomNavigationBarElevation(
        ThemeService.defaultBottomNavigationBarElevation, false);
    await setNavBarStyle(ThemeService.defaultNavBarStyle, false);
    await setUseNavDivider(ThemeService.defaultUseNavDivider, false);
    await setTooltipsMatchBackground(
        ThemeService.defaultTooltipsMatchBackground, false);
    await setSwapLightColors(ThemeService.defaultSwapLightColors, false);
    await setSwapDarkColors(ThemeService.defaultSwapDarkColors, false);
    await setLightIsWhite(ThemeService.defaultLightIsWhite, false);
    await setDarkIsTrueBlack(ThemeService.defaultDarkIsTrueBlack, false);
    await setUseToDarkMethod(ThemeService.defaultUseToDarkMethod, false);
    await setDarkMethodLevel(ThemeService.defaultDarkMethodLevel, false);
    await setUseFlexColorScheme(ThemeService.defaultUseFlexColorScheme, false);
    await setBlendLightOnColors(ThemeService.defaultBlendLightOnColors, false);
    await setBlendDarkOnColors(ThemeService.defaultBlendDarkOnColors, false);
    await setBlendLightTextTheme(
        ThemeService.defaultBlendLightTextTheme, false);
    await setBlendDarkTextTheme(ThemeService.defaultBlendDarkTextTheme, false);
    await setFabUseShape(ThemeService.defaultFabUseShape, false);
    // Custom colors
    await setPrimaryLight(ThemeService.defaultPrimaryLight, false);
    await setPrimaryContainerLight(
        ThemeService.defaultPrimaryContainerLight, false);
    await setSecondaryLight(ThemeService.defaultSecondaryLight, false);
    await setSecondaryContainerLight(
        ThemeService.defaultSecondaryContainerLight, false);
    await setPrimaryDark(ThemeService.defaultPrimaryDark, false);
    await setPrimaryContainerDark(
        ThemeService.defaultPrimaryContainerDark, false);
    await setSecondaryDark(ThemeService.defaultSecondaryDark, false);
    await setSecondaryContainerDark(
        ThemeService.defaultSecondaryContainerDark, false);
    // Not using ThemeService, just a locally controlled switched.
    await setPlatform(defaultTargetPlatform, false);
    notifyListeners();
  }

  // Make all ThemeController properties private so they cannot be used
  // directly without also persisting the changes using the ThemeService,
  // by making a setter and getter for each property.

  // Private value, getter and setter for the ThemeMode
  late ThemeMode _themeMode;

  /// Getter for the current ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// Set and persist new ThemeMode value.
  Future<void> setThemeMode(ThemeMode? value, [bool notify = true]) async {
    // No work if null value passed.
    if (value == null) return;
    // Do not perform any work if new and old value are identical.
    if (value == _themeMode) return;
    // Otherwise, assign new value to private property.
    _themeMode = value;
    // Inform all listeners a change has occurred, if notify flag true.
    if (notify) notifyListeners();
    // Persist the change to whatever storage is used with the ThemeService.
    await _themeService.saveThemeMode(value);
  }

  // Repeat above pattern for all other theme settings. The properties will
  // not be further explained, property names correspond to equivalent
  // FlexColorScheme properties.
  late bool _useSubThemes;
  bool get useSubThemes => _useSubThemes;
  Future<void> setUseSubThemes(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useSubThemes) return;
    _useSubThemes = value;
    if (notify) notifyListeners();
    await _themeService.saveUseSubThemes(value);
  }

  late bool _useTextTheme;
  bool get useTextTheme => _useTextTheme;
  Future<void> setUseTextTheme(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useTextTheme) return;
    _useTextTheme = value;
    if (notify) notifyListeners();
    await _themeService.saveUseTextTheme(value);
  }

  late FlexScheme _usedScheme;
  FlexScheme get usedScheme => _usedScheme;
  Future<void> setUsedScheme(FlexScheme? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _usedScheme) return;
    _usedScheme = value;
    if (notify) notifyListeners();
    await _themeService.saveUsedScheme(value);
  }

  late int _schemeIndex;
  int get schemeIndex => _schemeIndex;
  Future<void> setSchemeIndex(int? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _schemeIndex) return;
    _schemeIndex = value;
    notifyListeners();
    await _themeService.saveSchemeIndex(value);
  }

  late FlexSurfaceMode _surfaceMode;
  FlexSurfaceMode get surfaceMode => _surfaceMode;
  Future<void> setSurfaceMode(FlexSurfaceMode? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _surfaceMode) return;
    _surfaceMode = value;
    if (notify) notifyListeners();
    await _themeService.saveSurfaceMode(value);
  }

  late int _blendLevel;
  int get blendLevel => _blendLevel;
  Future<void> setBlendLevel(int? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _blendLevel) return;
    _blendLevel = value;
    if (notify) notifyListeners();
    await _themeService.saveBlendLevel(value);
  }

  late bool _interactionEffects;
  bool get interactionEffects => _interactionEffects;
  Future<void> setInteractionEffects(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _interactionEffects) return;
    _interactionEffects = value;
    if (notify) notifyListeners();
    await _themeService.saveInteractionEffects(value);
  }

  late bool _useDefaultRadius;
  bool get useDefaultRadius => _useDefaultRadius;
  Future<void> setUseDefaultRadius(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useDefaultRadius) return;
    _useDefaultRadius = value;
    if (notify) notifyListeners();
    await _themeService.saveUseDefaultRadius(value);
  }

  late double _cornerRadius;
  double get cornerRadius => _cornerRadius;
  Future<void> setCornerRadius(double? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _cornerRadius) return;
    _cornerRadius = value;
    if (notify) notifyListeners();
    await _themeService.saveCornerRadius(value);
  }

  late bool _inputDecoratorIsFilled;
  bool get inputDecoratorIsFilled => _inputDecoratorIsFilled;
  Future<void> setInputDecoratorIsFilled(bool? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _inputDecoratorIsFilled) return;
    _inputDecoratorIsFilled = value;
    if (notify) notifyListeners();
    await _themeService.saveInputDecoratorIsFilled(value);
  }

  late FlexInputBorderType _inputDecoratorBorderType;
  FlexInputBorderType get inputDecoratorBorderType => _inputDecoratorBorderType;
  Future<void> setInputDecoratorBorderType(FlexInputBorderType? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _inputDecoratorBorderType) return;
    _inputDecoratorBorderType = value;
    if (notify) notifyListeners();
    await _themeService.saveInputDecoratorBorderType(value);
  }

  late bool _inputDecoratorUnfocusedHasBorder;
  bool get inputDecoratorUnfocusedHasBorder =>
      _inputDecoratorUnfocusedHasBorder;
  Future<void> setInputDecoratorUnfocusedHasBorder(bool? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _inputDecoratorUnfocusedHasBorder) return;
    _inputDecoratorUnfocusedHasBorder = value;
    if (notify) notifyListeners();
    await _themeService.saveInputDecoratorUnfocusedHasBorder(value);
  }

  late FlexAppBarStyle _lightAppBarStyle;
  FlexAppBarStyle get lightAppBarStyle => _lightAppBarStyle;
  Future<void> setLightAppBarStyle(FlexAppBarStyle? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _lightAppBarStyle) return;
    _lightAppBarStyle = value;
    if (notify) notifyListeners();
    await _themeService.saveLightAppBarStyle(value);
  }

  late FlexAppBarStyle _darkAppBarStyle;
  FlexAppBarStyle get darkAppBarStyle => _darkAppBarStyle;
  Future<void> setDarkAppBarStyle(FlexAppBarStyle? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _darkAppBarStyle) return;
    _darkAppBarStyle = value;
    if (notify) notifyListeners();
    await _themeService.saveDarkAppBarStyle(value);
  }

  late double _appBarOpacity;
  double get appBarOpacity => _appBarOpacity;
  Future<void> setAppBarOpacity(double? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _appBarOpacity) return;
    _appBarOpacity = value;
    if (notify) notifyListeners();
    await _themeService.saveAppBarOpacity(value);
  }

  late double _appBarElevation;
  double get appBarElevation => _appBarElevation;
  Future<void> setAppBarElevation(double? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _appBarElevation) return;
    _appBarElevation = value;
    if (notify) notifyListeners();
    await _themeService.saveAppBarElevation(value);
  }

  late bool _transparentStatusBar;
  bool get transparentStatusBar => _transparentStatusBar;
  Future<void> setTransparentStatusBar(bool? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _transparentStatusBar) return;
    _transparentStatusBar = value;
    if (notify) notifyListeners();
    await _themeService.saveTransparentStatusBar(value);
  }

  late FlexTabBarStyle _tabBarStyle;
  FlexTabBarStyle get tabBarStyle => _tabBarStyle;
  Future<void> setTabBarStyle(FlexTabBarStyle? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _tabBarStyle) return;
    _tabBarStyle = value;
    if (notify) notifyListeners();
    await _themeService.saveTabBarStyle(value);
  }

  late double _bottomNavigationBarOpacity;
  double get bottomNavigationBarOpacity => _bottomNavigationBarOpacity;
  Future<void> setBottomNavigationBarOpacity(double? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _bottomNavigationBarOpacity) return;
    _bottomNavigationBarOpacity = value;
    if (notify) notifyListeners();
    await _themeService.saveBottomNavigationBarOpacity(value);
  }

  late double _bottomNavigationBarElevation;
  double get bottomNavigationBarElevation => _bottomNavigationBarElevation;
  Future<void> setBottomNavigationBarElevation(double? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _bottomNavigationBarElevation) return;
    _bottomNavigationBarElevation = value;
    if (notify) notifyListeners();
    await _themeService.saveBottomNavigationBarElevation(value);
  }

  late FlexSystemNavBarStyle _navBarStyle;
  FlexSystemNavBarStyle get navBarStyle => _navBarStyle;
  Future<void> setNavBarStyle(FlexSystemNavBarStyle? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _navBarStyle) return;
    _navBarStyle = value;
    if (notify) notifyListeners();
    await _themeService.saveNavBarStyle(value);
  }

  late bool _useNavDivider;
  bool get useNavDivider => _useNavDivider;
  Future<void> setUseNavDivider(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useNavDivider) return;
    _useNavDivider = value;
    if (notify) notifyListeners();
    await _themeService.saveUseNavDivider(value);
  }

  late bool _tooltipsMatchBackground;
  bool get tooltipsMatchBackground => _tooltipsMatchBackground;
  Future<void> setTooltipsMatchBackground(bool? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _tooltipsMatchBackground) return;
    _tooltipsMatchBackground = value;
    if (notify) notifyListeners();
    await _themeService.saveTooltipsMatchBackground(value);
  }

  late bool _swapLightColors;
  bool get swapLightColors => _swapLightColors;
  Future<void> setSwapLightColors(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _swapLightColors) return;
    _swapLightColors = value;
    if (notify) notifyListeners();
    await _themeService.saveSwapLightColors(value);
  }

  late bool _swapDarkColors;
  bool get swapDarkColors => _swapDarkColors;
  Future<void> setSwapDarkColors(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _swapDarkColors) return;
    _swapDarkColors = value;
    if (notify) notifyListeners();
    await _themeService.saveSwapDarkColors(value);
  }

  late bool _lightIsWhite;
  bool get lightIsWhite => _lightIsWhite;
  Future<void> setLightIsWhite(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _lightIsWhite) return;
    _lightIsWhite = value;
    if (notify) notifyListeners();
    await _themeService.saveLightIsWhite(value);
  }

  late bool _darkIsTrueBlack;
  bool get darkIsTrueBlack => _darkIsTrueBlack;
  Future<void> setDarkIsTrueBlack(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _darkIsTrueBlack) return;
    _darkIsTrueBlack = value;
    if (notify) notifyListeners();
    await _themeService.saveDarkIsTrueBlack(value);
  }

  late bool _useToDarkMethod;
  bool get useToDarkMethod => _useToDarkMethod;
  Future<void> setUseToDarkMethod(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useToDarkMethod) return;
    _useToDarkMethod = value;
    if (notify) notifyListeners();
    await _themeService.saveUseToDarkMethod(value);
  }

  late int _darkMethodLevel;
  int get darkMethodLevel => _darkMethodLevel;
  Future<void> setDarkMethodLevel(int? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _darkMethodLevel) return;
    _darkMethodLevel = value;
    if (notify) notifyListeners();
    await _themeService.saveDarkMethodLevel(value);
  }

  // This is not a FlexColorScheme property, it is a feature used to turn
  // ON/OFF the usage of FlexColorScheme
  late bool _useFlexColorScheme;
  bool get useFlexColorScheme => _useFlexColorScheme;
  Future<void> setUseFlexColorScheme(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _useFlexColorScheme) return;
    _useFlexColorScheme = value;
    if (notify) notifyListeners();
    await _themeService.saveUseFlexColorScheme(value);
  }

  // On color blending ON/OFF
  late bool _blendLightOnColors;
  bool get blendLightOnColors => _blendLightOnColors;
  Future<void> setBlendLightOnColors(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _blendLightOnColors) return;
    _blendLightOnColors = value;
    if (notify) notifyListeners();
    await _themeService.saveBlendLightOnColors(value);
  }

  late bool _blendDarkOnColors;
  bool get blendDarkOnColors => _blendDarkOnColors;
  Future<void> setBlendDarkOnColors(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _blendDarkOnColors) return;
    _blendDarkOnColors = value;
    if (notify) notifyListeners();
    await _themeService.saveBlendDarkOnColors(value);
  }

  // TextThem blending ON/OFF
  late bool _blendLightTextTheme;
  bool get blendLightTextTheme => _blendLightTextTheme;
  Future<void> setBlendLightTextTheme(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _blendLightTextTheme) return;
    _blendLightTextTheme = value;
    if (notify) notifyListeners();
    await _themeService.saveBlendLightTextTheme(value);
  }

  late bool _blendDarkTextTheme;
  bool get blendDarkTextTheme => _blendDarkTextTheme;
  Future<void> setBlendDarkTextTheme(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _blendDarkTextTheme) return;
    _blendDarkTextTheme = value;
    if (notify) notifyListeners();
    await _themeService.saveBlendDarkTextTheme(value);
  }

  late bool _fabUseShape;
  bool get fabUseShape => _fabUseShape;
  Future<void> setFabUseShape(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _fabUseShape) return;
    _fabUseShape = value;
    if (notify) notifyListeners();
    await _themeService.saveFabUseShape(value);
  }

  late Color _primaryLight;
  Color get primaryLight => _primaryLight;
  Future<void> setPrimaryLight(Color? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _primaryLight) return;
    _primaryLight = value;
    if (notify) notifyListeners();
    await _themeService.savePrimaryLight(value);
  }

  late Color _primaryContainerLight;
  Color get primaryContainerLight => _primaryContainerLight;
  Future<void> setPrimaryContainerLight(Color? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _primaryContainerLight) return;
    _primaryContainerLight = value;
    if (notify) notifyListeners();
    await _themeService.savePrimaryContainerLight(value);
  }

  late Color _secondaryLight;
  Color get secondaryLight => _secondaryLight;
  Future<void> setSecondaryLight(Color? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _secondaryLight) return;
    _secondaryLight = value;
    if (notify) notifyListeners();
    await _themeService.saveSecondaryLight(value);
  }

  late Color _secondaryContainerLight;
  Color get secondaryContainerLight => _secondaryContainerLight;
  Future<void> setSecondaryContainerLight(Color? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _secondaryContainerLight) return;
    _secondaryContainerLight = value;
    if (notify) notifyListeners();
    await _themeService.saveSecondaryContainerLight(value);
  }

  late Color _primaryDark;
  Color get primaryDark => _primaryDark;
  Future<void> setPrimaryDark(Color? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _primaryDark) return;
    _primaryDark = value;
    if (notify) notifyListeners();
    await _themeService.savePrimaryDark(value);
  }

  late Color _primaryContainerDark;
  Color get primaryContainerDark => _primaryContainerDark;
  Future<void> setPrimaryContainerDark(Color? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _primaryContainerDark) return;
    _primaryContainerDark = value;
    if (notify) notifyListeners();
    await _themeService.savePrimaryContainerDark(value);
  }

  late Color _secondaryDark;
  Color get secondaryDark => _secondaryDark;
  Future<void> setSecondaryDark(Color? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _secondaryDark) return;
    _secondaryDark = value;
    if (notify) notifyListeners();
    await _themeService.saveSecondaryDark(value);
  }

  late Color _secondaryContainerDark;
  Color get secondaryContainerDark => _secondaryContainerDark;
  Future<void> setSecondaryContainerDark(Color? value,
      [bool notify = true]) async {
    if (value == null) return;
    if (value == _secondaryContainerDark) return;
    _secondaryContainerDark = value;
    if (notify) notifyListeners();
    await _themeService.saveSecondaryContainerDark(value);
  }

  // Get custom scheme data based on currently defined scheme colors.
  FlexSchemeData get customScheme => FlexSchemeData(
        name: FlexColor.customName,
        description: FlexColor.customDescription,
        light: FlexSchemeColor(
          primary: primaryLight,
          primaryContainer: primaryContainerLight,
          secondary: secondaryLight,
          secondaryContainer: secondaryContainerLight,
          appBarColor: secondaryContainerLight,
          error: FlexColor.materialLightError,
        ),
        dark: FlexSchemeColor(
          primary: primaryDark,
          primaryContainer: primaryContainerDark,
          secondary: secondaryDark,
          secondaryContainer: secondaryContainerDark,
          appBarColor: secondaryContainerDark,
          error: FlexColor.materialDarkError,
        ),
      );

  // Set the custom scheme colors to the colors scheme FlexSchemeData.
  Future<void> setCustomScheme(FlexSchemeData scheme) async {
    // Don't notify listeners while setting new values for each value.
    await setPrimaryLight(scheme.light.primary, false);
    await setPrimaryContainerLight(scheme.light.primaryContainer, false);
    await setSecondaryLight(scheme.light.secondary, false);
    await setSecondaryContainerLight(scheme.light.secondaryContainer, false);
    await setPrimaryDark(scheme.dark.primary, false);
    await setPrimaryContainerDark(scheme.dark.primaryContainer, false);
    await setSecondaryDark(scheme.dark.secondary, false);
    await setSecondaryContainerDark(scheme.dark.secondaryContainer, false);
    // Notify listeners, after all individual values have been set.
    notifyListeners();
  }

  /// This is just a local controller properties for the Platform menu control.
  /// It is used as input to the theme, but never persisted so it always
  /// defaults to the actual target platform when starting the app.
  /// Being able to toggle it during demos and development is a handy feature.
  late TargetPlatform _platform;
  TargetPlatform get platform => _platform;
  Future<void> setPlatform(TargetPlatform? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _platform) return;
    _platform = value;
    if (notify) notifyListeners();
  }

  // Recently used colors, we keep the list of recently used colors in the
  // color picker for custom colors only during the session we don't persist.
  // It is of course possible to persist, but not needed in ths demo.
  List<Color> _recentColors = <Color>[];
  List<Color> get recentColors => _recentColors;
  // ignore: use_setters_to_change_properties
  void setRecentColors(final List<Color> colors) {
    _recentColors = colors;
  }
}
