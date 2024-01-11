import 'package:shared_preferences/shared_preferences.dart';

Future<Set<String>> loadFavorites() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favoriteList = prefs.getStringList('favorites') ?? [];
  return favoriteList.toSet();
}

Future<void> toggleFavorite(
    String cryptoId, Set<String> currentFavorites) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (currentFavorites.contains(cryptoId)) {
    currentFavorites.remove(cryptoId);
  } else {
    currentFavorites.add(cryptoId);
  }

  await prefs.setStringList('favorites', currentFavorites.toList());
}

Future<void> setThemeMode(bool isDarkMode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', isDarkMode);
}

Future<bool> getThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false; // Default to light mode
}
