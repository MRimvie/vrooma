import 'package:get/get.dart';
import '../../models/ride_model.dart';
import '../../services/mock_ride_service.dart';
import '../../services/mock_auth_service.dart';

class RideHistoryController extends GetxController {
  final MockRideService _rideService = MockRideService();
  final MockAuthService _authService = MockAuthService();

  final RxList<RideModel> rides = <RideModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRides();
  }

  Future<void> loadRides() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final ridesList = await _rideService.getUserRides(userId, limit: 50);
        rides.value = ridesList;
      }
    } catch (e) {
      print('Error loading rides: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewRideDetails(RideModel ride) {
    Get.toNamed('/ride-details', arguments: {'ride': ride});
  }
}
