import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device preferences only. Identity, bank details and official records must
/// never be written to this store.
class AppPreferences extends ChangeNotifier {
  AppPreferences({this.storage});

  static final instance = AppPreferences();
  final SharedPreferencesAsync? storage;
  late final SharedPreferencesAsync _preferences =
      storage ?? SharedPreferencesAsync();
  Future<void> _pendingWrite = Future.value();
  bool _hindi = true;
  bool _lowData = true;
  bool _largeText = false;
  bool _saveFailed = false;

  bool get hindi => _hindi;
  bool get lowData => _lowData;
  bool get largeText => _largeText;
  bool get saveFailed => _saveFailed;

  String text(String english, String hindi) => _hindi ? hindi : english;

  static AppPreferences of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AppPreferencesScope>()
          ?.notifier ??
      instance;

  Future<void> load() async {
    try {
      final values = await Future.wait([
        _preferences.getBool('preferences.hindi'),
        _preferences.getBool('preferences.lowData'),
        _preferences.getBool('preferences.largeText'),
      ]);
      _hindi = values[0] ?? true;
      _lowData = values[1] ?? true;
      _largeText = values[2] ?? false;
      _saveFailed = false;
    } catch (_) {
      // A blocked browser store must not prevent access to offline guidance.
      _saveFailed = true;
    }
    notifyListeners();
  }

  Future<void> setHindi(bool value) {
    _hindi = value;
    notifyListeners();
    return _save('preferences.hindi', value);
  }

  Future<void> setLowData(bool value) {
    _lowData = value;
    notifyListeners();
    return _save('preferences.lowData', value);
  }

  Future<void> setLargeText(bool value) {
    _largeText = value;
    notifyListeners();
    return _save('preferences.largeText', value);
  }

  Future<void> _save(String key, bool value) {
    // Keep rapid toggles in order so an earlier write cannot win a race.
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _preferences.setBool(key, value);
        _saveFailed = false;
      } catch (_) {
        _saveFailed = true;
      }
      notifyListeners();
    });
    return _pendingWrite;
  }
}

class AppPreferencesScope extends InheritedNotifier<AppPreferences> {
  const AppPreferencesScope({
    super.key,
    required AppPreferences preferences,
    required super.child,
  }) : super(notifier: preferences);
}
