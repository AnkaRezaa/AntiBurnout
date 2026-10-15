import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesDetails {
  const PreferencesDetails({
    this.themeMode = ThemeMode.system,
    this.dailyReminder = false,
    this.wellbeingTips = true,
  });

  final ThemeMode themeMode;
  final bool dailyReminder;
  final bool wellbeingTips;
}

/// Theme changes apply immediately; reminder choices remain UI previews.
class PreferencesController extends Notifier<PreferencesDetails> {
  @override
  PreferencesDetails build() => const PreferencesDetails();

  void setThemeMode(ThemeMode mode) {
    state = PreferencesDetails(
      themeMode: mode,
      dailyReminder: state.dailyReminder,
      wellbeingTips: state.wellbeingTips,
    );
  }

  void setDailyReminder(bool enabled) {
    state = PreferencesDetails(
      themeMode: state.themeMode,
      dailyReminder: enabled,
      wellbeingTips: state.wellbeingTips,
    );
  }

  void setWellbeingTips(bool enabled) {
    state = PreferencesDetails(
      themeMode: state.themeMode,
      dailyReminder: state.dailyReminder,
      wellbeingTips: enabled,
    );
  }
}

final preferencesControllerProvider =
    NotifierProvider<PreferencesController, PreferencesDetails>(
      PreferencesController.new,
    );
