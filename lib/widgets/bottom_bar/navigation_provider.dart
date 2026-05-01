import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() => setCurrentIndex(0);
  void goToHistory() => setCurrentIndex(1);
  void goToActivity() => setCurrentIndex(2);
  void goToProfile() => setCurrentIndex(3);
}
