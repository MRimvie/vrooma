import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/location_service.dart';
import '../../services/mock_ride_service.dart';
import '../../helpers/services/mock_socket_service.dart';
import '../../services/mock_auth_service.dart';
import '../../models/ride_model.dart';

class DriverHomeController extends GetxController {
  final LocationService _locationService = LocationService();
  final MockRideService _rideService = MockRideService();
  final MockSocketService _socketService = Get.find<MockSocketService>();
  final MockAuthService _authService = MockAuthService();

  MapController? mapController;
  final LatLng initialPosition = const LatLng(12.3714, -1.5197);

  final RxList<Marker> markers = <Marker>[].obs;
  final RxBool isOnline = false.obs;
  final RxString driverName = 'Chauffeur'.obs;
  final RxInt todayRides = 0.obs;
  final RxDouble todayEarnings = 0.0.obs;
  final RxInt onlineTime = 0.obs;

  final RxBool hasNewRideRequest = false.obs;
  final RxString ridePickupAddress = ''.obs;
  final RxString rideDestinationAddress = ''.obs;
  final RxDouble rideDistance = 0.0.obs;
  final RxInt rideDuration = 0.obs;
  final RxDouble ridePrice = 0.0.obs;
  final RxInt requestTimer = 30.obs;

  String? currentRideId;
  Timer? _locationTimer;
  Timer? _requestTimer;
  StreamSubscription? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadDriverInfo();
    _listenToRideRequests();
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    _requestTimer?.cancel();
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _loadDriverInfo() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      final userData = await _authService.getUserData(userId);
      if (userData != null) {
        driverName.value = '${userData['firstName']} ${userData['lastName']}';
      }
    }
  }

  void _listenToRideRequests() {
    _socketService.listenToRideRequests((data) {
      if (isOnline.value) {
        currentRideId = data['rideId'];
        ridePickupAddress.value = data['pickupAddress'] ?? '';
        rideDestinationAddress.value = data['destinationAddress'] ?? '';
        rideDistance.value = (data['distance'] ?? 0).toDouble();
        rideDuration.value = data['duration'] ?? 0;
        ridePrice.value = (data['price'] ?? 0).toDouble();
        
        hasNewRideRequest.value = true;
        _startRequestTimer();
      }
    });
  }

  void _startRequestTimer() {
    requestTimer.value = 30;
    _requestTimer?.cancel();
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (requestTimer.value > 0) {
        requestTimer.value--;
      } else {
        timer.cancel();
        declineRide();
      }
    });
  }

  void onMapCreated(MapController controller) {
    mapController = controller;
  }

  Future<void> toggleOnlineStatus(bool status) async {
    isOnline.value = status;
    
    if (status) {
      await _startLocationTracking();
      Fluttertoast.showToast(
        msg: 'Vous êtes maintenant en ligne',
        backgroundColor: Colors.green,
      );
    } else {
      _stopLocationTracking();
      Fluttertoast.showToast(
        msg: 'Vous êtes maintenant hors ligne',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _startLocationTracking() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _locationSubscription = _locationService.getLocationStream().listen((position) {
        final driverId = _authService.currentUserId;
        if (driverId != null) {
          _socketService.emitDriverLocation(
            driverId,
            position.latitude,
            position.longitude,
            position.heading,
          );
        }
      });
    }
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
  }

  void openDrawer() {
    Get.toNamed('/driver/menu');
  }

  Future<void> acceptRide() async {
    if (currentRideId == null) return;

    _requestTimer?.cancel();
    hasNewRideRequest.value = false;

    try {
      final driverId = _authService.currentUserId;
      if (driverId == null) throw Exception('Driver not authenticated');

      final driverInfo = {
        'name': driverName.value,
        'phone': '+237600000000',
        'vehicle': 'Toyota Corolla',
        'plateNumber': 'LT 1234 AA',
        'rating': 4.8,
      };

      await _rideService.acceptRide(currentRideId!, driverId, driverInfo);
      _socketService.emitRideAccepted(currentRideId!, driverId);

      todayRides.value++;
      todayEarnings.value += ridePrice.value;

      Get.toNamed('/driver/ride-active', arguments: {'rideId': currentRideId});

      Fluttertoast.showToast(
        msg: 'Course acceptée',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'acceptation',
        backgroundColor: Colors.red,
      );
    }
  }

  void declineRide() {
    _requestTimer?.cancel();
    hasNewRideRequest.value = false;
    currentRideId = null;
  }
}
