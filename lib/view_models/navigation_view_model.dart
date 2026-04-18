import 'package:flutter/material.dart';
import 'package:randki/screens/home_screen.dart';
import 'package:randki/screens/map_screen.dart';
import 'package:randki/screens/profile_screen.dart';

class NavigationViewModel extends ChangeNotifier {
  NavigationViewModel({this.selectedIndex = 0});

  int selectedIndex;
  Widget currentScreen = HomeScreen();

  final List<Widget> screens = const [
    HomeScreen(),
    MapScreen(),
    ProfileScreen(),
  ];


  void onDestinationSelected(int index) {
    selectedIndex = index;
    currentScreen = screens[index];
    notifyListeners();
  }
}
