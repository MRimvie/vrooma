import 'package:get/get.dart';

class MockSocketService extends GetxService {
  bool isConnected = false;

  Future<MockSocketService> init() async {
    print('🔌 Mock Socket Service initialized');
    return this;
  }

  void connect(String userId) {
    isConnected = true;
    print('🔌 Mock Socket connected for user: $userId');
  }

  void disconnect() {
    isConnected = false;
    print('🔌 Mock Socket disconnected');
  }

  void emitDriverLocation(String driverId, double latitude, double longitude, double heading) {
    print('📍 Mock: Driver $driverId location: ($latitude, $longitude)');
  }

  void emitRideAccepted(String rideId, String driverId) {
    print('✅ Mock: Ride $rideId accepted by driver $driverId');
  }

  void listenToDriverLocation(Function(Map<String, dynamic>) callback) {
    print('👂 Mock: Listening to driver location updates');
  }

  void listenToRideRequests(Function(Map<String, dynamic>) callback) {
    print('👂 Mock: Listening to ride requests');
  }

  void listenToRideStatusUpdates(Function(Map<String, dynamic>) callback) {
    print('👂 Mock: Listening to ride status updates');
  }
}
