import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_bar/bottom_nav_bar.dart';
import '../../widgets/bottom_bar/navigation_provider.dart';
import 'home_map_page.dart';
import 'ride_history_page.dart';
import 'activity_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: const [
              HomeMapPage(),
              RideHistoryPage(),
              ActivityPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: navigationProvider.currentIndex,
            onTabChange: (index) {
              navigationProvider.setCurrentIndex(index);
            },
          ),
        );
      },
    );
  }
}
