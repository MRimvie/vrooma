import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/mock_ride_service.dart';
import '../../models/ride_model.dart';

class RideTrackingController extends GetxController {
  final MockRideService _rideService = Get.find<MockRideService>();

  MapController? mapController;

  final RxList<Marker> markers = <Marker>[].obs;
  final RxList<Polyline> polylines = <Polyline>[].obs;

  final Rx<RideStatus> rideStatus = RideStatus.pending.obs;
  final RxString estimatedTime = 'Calcul...'.obs;
  final RxString driverName = ''.obs;
  final RxDouble driverRating = 5.0.obs;
  final RxString vehicleModel = ''.obs;
  final RxString vehiclePlate = ''.obs;
  final RxString driverPhone = ''.obs;
  final RxString driverETA = '5 min'.obs;
  final RxDouble driverDistance = 0.0.obs;
  final RxDouble rideProgress = 0.0.obs;
  final RxString estimatedArrival = ''.obs;
  final RxDouble finalPrice = 0.0.obs;

  // True when driver has arrived and client must tap "Confirmer la montée"
  final RxBool awaitingBoardingConfirmation = false.obs;

  late String rideId;
  LatLng? _pickupPoint;
  LatLng? _destinationPoint;

  final List<LatLng> _fullRoute = [];
  int _currentRouteIndex = 0;

  StreamSubscription? _rideSubscription;
  Timer? _animationTimer;

  static const _primaryColor = Color(0xFF3874FF);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    rideId = args['rideId'];

    final pLat = args['pickupLat'] as double?;
    final pLng = args['pickupLng'] as double?;
    final dLat = args['destinationLat'] as double?;
    final dLng = args['destinationLng'] as double?;

    if (pLat != null && pLng != null && dLat != null && dLng != null) {
      _pickupPoint = LatLng(pLat, pLng);
      _destinationPoint = LatLng(dLat, dLng);
      _buildRoute();
    }

    final arrival = DateTime.now().add(const Duration(minutes: 18));
    estimatedArrival.value =
        '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';

    _listenToRideUpdates();
  }

  @override
  void onClose() {
    _rideSubscription?.cancel();
    _animationTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Route construction — cubic Bézier through two control points
  // ---------------------------------------------------------------------------

  void _buildRoute() {
    if (_pickupPoint == null || _destinationPoint == null) return;
    _fullRoute.clear();

    final p = _pickupPoint!;
    final d = _destinationPoint!;
    final dLat = d.latitude - p.latitude;
    final dLng = d.longitude - p.longitude;
    final dist = sqrt(dLat * dLat + dLng * dLng);

    if (dist < 1e-6) return;

    // Perpendicular unit vector × 25% of total distance → realistic detour
    final perpScale = dist * 0.25;
    final perpLat = -dLng / dist * perpScale;
    final perpLng = dLat / dist * perpScale;

    // Two control points create an S-curve (simulates street routing)
    final ctrl1 = LatLng(
      p.latitude + dLat * 0.3 + perpLat,
      p.longitude + dLng * 0.3 + perpLng,
    );
    final ctrl2 = LatLng(
      p.latitude + dLat * 0.7 - perpLat,
      p.longitude + dLng * 0.7 - perpLng,
    );

    _fullRoute.addAll(_cubicBezier(p, ctrl1, ctrl2, d, 80));
    _drawPolylines(0);
    _addStaticMarkers();
  }

  List<LatLng> _cubicBezier(
      LatLng p0, LatLng p1, LatLng p2, LatLng p3, int n) {
    return List.generate(n + 1, (i) {
      final t = i / n;
      final mt = 1.0 - t;
      return LatLng(
        mt * mt * mt * p0.latitude +
            3 * mt * mt * t * p1.latitude +
            3 * mt * t * t * p2.latitude +
            t * t * t * p3.latitude,
        mt * mt * mt * p0.longitude +
            3 * mt * mt * t * p1.longitude +
            3 * mt * t * t * p2.longitude +
            t * t * t * p3.longitude,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Polyline rendering — dual-stroke (white shadow + primary color)
  // ---------------------------------------------------------------------------

  void _drawPolylines(int driverIndex) {
    if (_fullRoute.isEmpty) return;
    final newPolylines = <Polyline>[];

    // Completed portion — light grey
    if (driverIndex > 0) {
      newPolylines.add(Polyline(
        points: _fullRoute.sublist(0, driverIndex + 1),
        color: Colors.grey.shade300,
        strokeWidth: 5,
      ));
    }

    // Remaining portion — white shadow then primary color on top
    if (driverIndex < _fullRoute.length - 1) {
      final ahead = _fullRoute.sublist(driverIndex);
      newPolylines.add(Polyline(
        points: ahead,
        color: Colors.white,
        strokeWidth: 9,
      ));
      newPolylines.add(Polyline(
        points: ahead,
        color: _primaryColor,
        strokeWidth: 5,
      ));
    }

    polylines.value = newPolylines;
  }

  // ---------------------------------------------------------------------------
  // Markers
  // ---------------------------------------------------------------------------

  void _addStaticMarkers() {
    final list = <Marker>[];

    if (_pickupPoint != null) {
      list.add(Marker(
        point: _pickupPoint!,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child: const Icon(Icons.my_location, color: Colors.white, size: 22),
        ),
      ));
    }

    if (_destinationPoint != null) {
      list.add(Marker(
        point: _destinationPoint!,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 22),
        ),
      ));
    }

    markers.value = list;
  }

  void _updateDriverMarker(LatLng position, int index) {
    // Compute heading from previous point for arrow rotation
    double bearing = 0;
    if (index > 0) {
      final prev = _fullRoute[index - 1];
      bearing = atan2(
        position.longitude - prev.longitude,
        position.latitude - prev.latitude,
      );
    }

    final list = <Marker>[];

    if (_pickupPoint != null) {
      list.add(Marker(
        point: _pickupPoint!,
        width: 36,
        height: 36,
        child: Container(
          decoration:
              const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child:
              const Icon(Icons.my_location, color: Colors.white, size: 18),
        ),
      ));
    }

    if (_destinationPoint != null) {
      list.add(Marker(
        point: _destinationPoint!,
        width: 36,
        height: 36,
        child: Container(
          decoration:
              const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 18),
        ),
      ));
    }

    // Animated taxi with directional arrow
    list.add(Marker(
      point: position,
      width: 54,
      height: 54,
      child: Transform.rotate(
        angle: bearing,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child: const Icon(Icons.navigation_rounded,
              color: _primaryColor, size: 30),
        ),
      ),
    ));

    markers.value = list;
    mapController?.move(position, 15.5);
    rideProgress.value = index / (_fullRoute.length - 1);
    final minsLeft = ((1 - rideProgress.value) * 18).round().clamp(0, 18);
    driverETA.value = minsLeft > 0 ? '$minsLeft min' : 'Arrivée imminente';
  }

  // ---------------------------------------------------------------------------
  // Ride stream listener
  // ---------------------------------------------------------------------------

  void _listenToRideUpdates() {
    _rideSubscription = _rideService.getRideStream(rideId).listen((ride) {
      if (ride == null) return;
      rideStatus.value = ride.status;

      if (ride.status == RideStatus.accepted) {
        _fillDriverInfo(ride);
        estimatedTime.value = 'Chauffeur en route';
        awaitingBoardingConfirmation.value = false;
        if (_fullRoute.isNotEmpty) _updateDriverMarker(_fullRoute.first, 0);
      }

      if (ride.status == RideStatus.driverArriving) {
        _fillDriverInfo(ride);
        estimatedTime.value = 'Votre chauffeur est là !';
        awaitingBoardingConfirmation.value = true;
        if (_fullRoute.isNotEmpty) _updateDriverMarker(_fullRoute.first, 0);
      }

      if (ride.status == RideStatus.inProgress) {
        awaitingBoardingConfirmation.value = false;
        estimatedTime.value = 'Course en cours';
        _startRouteAnimation();
      }

      if (ride.status == RideStatus.completed) {
        finalPrice.value = ride.finalPrice ?? ride.estimatedPrice;
        _animationTimer?.cancel();
        estimatedTime.value = 'Arrivé !';
        if (_fullRoute.isNotEmpty) {
          _updateDriverMarker(_fullRoute.last, _fullRoute.length - 1);
        }
      }
    });
  }

  void _fillDriverInfo(RideModel ride) {
    driverName.value = ride.driverName ?? 'Chauffeur';
    driverRating.value = ride.driverRating ?? 5.0;
    vehicleModel.value = ride.driverVehicle ?? 'Véhicule';
    vehiclePlate.value = ride.driverPlateNumber ?? '';
    driverPhone.value = ride.driverPhone ?? '';
  }

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  void _startRouteAnimation() {
    _currentRouteIndex = 0;
    _animationTimer?.cancel();

    _animationTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      if (_currentRouteIndex >= _fullRoute.length - 1) {
        t.cancel();
        return;
      }
      _currentRouteIndex++;
      _drawPolylines(_currentRouteIndex);
      _updateDriverMarker(_fullRoute[_currentRouteIndex], _currentRouteIndex);
    });
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void onMapCreated(MapController controller) {
    mapController = controller;
    if (_pickupPoint != null && _destinationPoint != null) {
      final midLat =
          (_pickupPoint!.latitude + _destinationPoint!.latitude) / 2;
      final midLng =
          (_pickupPoint!.longitude + _destinationPoint!.longitude) / 2;
      Future.delayed(const Duration(milliseconds: 500),
          () => mapController?.move(LatLng(midLat, midLng), 13.0));
    }
  }

  Future<void> confirmBoarding() async {
    await _rideService.clientConfirmBoarding(rideId);
    awaitingBoardingConfirmation.value = false;
  }

  Future<void> callDriver() async {
    final phone = driverPhone.value.isNotEmpty ? driverPhone.value : '+22675987654';
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> messageDriver() async {
    Get.snackbar('Chat', 'Fonctionnalité de chat bientôt disponible',
        snackPosition: SnackPosition.TOP);
  }

  Future<void> shareRide() async {
    await Share.share('Je suis en course avec Solidar. Trajet en cours !',
        subject: 'Suivi de course');
  }

  Future<void> cancelRide() async {
    try {
      await _rideService.cancelRide(rideId, 'Annulé par le client');
      _animationTimer?.cancel();
      Get.offAllNamed('/client/home');
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible d\'annuler la course');
    }
  }

  Future<void> rateDriver() async {
    Get.toNamed('/rate-driver', arguments: {
      'rideId': rideId,
      'driverId': 'driver_fatou_001',
      'driverName': driverName.value,
    });
  }
}
