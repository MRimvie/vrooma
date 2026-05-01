import 'package:vrooma/views/apps/change_language.dart';
import 'package:vrooma/views/apps/home/dashboard_screen.dart';
import 'package:vrooma/views/apps/home/home_page.dart';
import 'package:vrooma/views/apps/setting/settings_page.dart';
import 'package:vrooma/views/apps/setting/widget/select_language.dart';
import 'package:vrooma/views/auth/login_page.dart';
import 'package:vrooma/views/auth/register_page.dart';
import 'package:vrooma/views/auth/forgot_password_page.dart';
import 'package:vrooma/views/auth/phone_auth_page.dart';
import 'package:vrooma/views/auth/otp_verification_page.dart';
import 'package:vrooma/views/client/home_map_page.dart';
import 'package:vrooma/views/client/main_navigation_page.dart';
import 'package:vrooma/views/client/ride_tracking_page.dart';
import 'package:vrooma/views/client/ride_history_page.dart';
import 'package:vrooma/views/client/search_location_page.dart';
import 'package:vrooma/views/driver/driver_home_page.dart';
import 'package:vrooma/views/common/payment_page.dart';
import 'package:vrooma/views/common/rating_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'services/mock_auth_service.dart';
import 'views/error_pages/coming_soon_page.dart';
import 'views/error_pages/error_404.dart';
import 'views/error_pages/error_500.dart';
import 'views/error_pages/maintenance_page.dart';

class AuthMiddleware extends GetMiddleware {
  final MockAuthService _authService = Get.find<MockAuthService>();
  
  @override
  RouteSettings? redirect(String? route) {
    // Routes publiques (pas besoin d'authentification)
    if (route == '/auth/login' || 
        route == '/auth/register' ||
        route == '/auth/forgot-password' ||
        route == '/auth/phone' || 
        route == '/auth/otp') {
      print("✅ Route publique autorisée: $route");
      return null;
    }
    
    // Vérifier si l'utilisateur est connecté
    if (!_authService.isAuthenticated) {
      print("❌ Non authentifié, redirection vers /auth/login");
      return const RouteSettings(name: '/auth/login');
    }
    
    print("✅ Utilisateur authentifié, accès autorisé à: $route");
    return null;
  }
}

getPageRoute() {
  var routes = [
    GetPage(name: '/dashboard', page: () => const HomePage()),
    GetPage(name: '/settingScreen', page: () => SettingScreen()),
    GetPage(name: '/HomeScreen', page: () => HomeScreen()),

    GetPage(name: '/selectLanguageScreen', page: () => SelectLanguageScreen()),
    GetPage(name: '/changeLanguageScreen', page: () => ChangeLanguageScreen()),

    ///---------------- Auth ----------------///
    GetPage(name: '/auth/login', page: () => const LoginPage()),
    GetPage(name: '/auth/register', page: () => const RegisterPage()),
    GetPage(name: '/auth/forgot-password', page: () => const ForgotPasswordPage()),
    GetPage(name: '/auth/phone', page: () => const PhoneAuthPage()),
    GetPage(name: '/auth/otp', page: () => const OTPVerificationPage()),

    ///---------------- Client ----------------///
    GetPage(
        name: '/client/home',
        page: () => const MainNavigationPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/search-location',
        page: () => const SearchLocationPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ride-tracking',
        page: () => const RideTrackingPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ride-history',
        page: () => const RideHistoryPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Driver ----------------///
    GetPage(
        name: '/driver/home',
        page: () => const DriverHomePage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Common ----------------///
    GetPage(
        name: '/payment',
        page: () => const PaymentPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/rate-driver',
        page: () => const RatingPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Error ----------------///
    GetPage(name: '/coming-soon', page: () => const ComingSoonPage()),
    GetPage(name: '/error-404', page: () => const Error404()),
    GetPage(name: '/error-500', page: () => const Error500()),
    GetPage(name: '/maintenance', page: () => const MaintenancePage()),
  ];
  return routes
      .map(
        (e) => GetPage(
            name: e.name,
            page: e.page,
            middlewares: e.middlewares,
            transition: Transition.noTransition),
      )
      .toList();
}

