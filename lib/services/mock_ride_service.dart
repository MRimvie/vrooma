import 'dart:async';
import 'package:get/get.dart';
import '../models/ride_model.dart';
import 'mock_data_service.dart';

class MockRideService {
  final RxList<RideModel> _mockRides = <RideModel>[].obs;

  // Completers indexed by rideId — unlocked when the client confirms boarding
  final Map<String, Completer<void>> _boardingConfirmations = {};

  Future<String> createRide(RideModel ride) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockRides.add(ride);
    return ride.id;
  }

  Future<void> updateRide(String rideId, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<RideModel?> getRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockRides.firstWhereOrNull((r) => r.id == rideId);
  }

  /// Called by the client when they confirm they have boarded the vehicle.
  Future<void> clientConfirmBoarding(String rideId) async {
    final completer = _boardingConfirmations[rideId];
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Stream<RideModel?> getRideStream(String rideId) async* {
    final original = _mockRides.firstWhereOrNull((r) => r.id == rideId);
    if (original == null) return;

    // 1. Pending — searching for a driver
    yield original;

    await Future.delayed(const Duration(seconds: 4));

    // 2. Accepted — driver assigned, en route to pickup
    final driverBase = {
      'driverId': 'driver_fatou_001',
      'driverName': 'Fatou Ouédraogo',
      'driverPhone': '+22675987654',
      'driverVehicle': 'Toyota Corolla',
      'driverPlateNumber': 'BF-4521-A',
      'driverRating': 4.8,
    };
    yield _withStatus(original, RideStatus.accepted, driverBase,
        acceptedAt: DateTime.now());

    await Future.delayed(const Duration(seconds: 7));

    // 3. DriverArriving — driver at pickup, waiting for client confirmation
    yield _withStatus(original, RideStatus.driverArriving, driverBase);

    // Wait for client to confirm boarding (max 90 s, then auto-start)
    final boarding = Completer<void>();
    _boardingConfirmations[rideId] = boarding;
    try {
      await boarding.future.timeout(const Duration(seconds: 90));
    } catch (_) {
      // Timeout — silently proceed
    }
    _boardingConfirmations.remove(rideId);

    // 4. InProgress — ride underway
    yield _withStatus(original, RideStatus.inProgress, driverBase,
        startedAt: DateTime.now());

    await Future.delayed(const Duration(seconds: 22));

    // 5. Completed
    yield _withStatus(original, RideStatus.completed, driverBase,
        completedAt: DateTime.now(), finalPrice: original.estimatedPrice);
  }

  RideModel _withStatus(
    RideModel base,
    RideStatus status,
    Map<String, dynamic> driver, {
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? finalPrice,
  }) {
    return RideModel(
      id: base.id,
      clientId: base.clientId,
      driverId: driver['driverId'],
      pickupLocation: base.pickupLocation,
      destinationLocation: base.destinationLocation,
      vehicleType: base.vehicleType,
      status: status,
      estimatedPrice: base.estimatedPrice,
      finalPrice: finalPrice,
      distance: base.distance,
      estimatedDuration: base.estimatedDuration,
      createdAt: base.createdAt,
      acceptedAt: acceptedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      driverName: driver['driverName'],
      driverPhone: driver['driverPhone'],
      driverVehicle: driver['driverVehicle'],
      driverPlateNumber: driver['driverPlateNumber'],
      driverRating: (driver['driverRating'] as num).toDouble(),
    );
  }

  Future<List<RideModel>> getUserRides(String userId, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = MockDataService.getMockRides();
    return data.take(limit).map((r) => RideModel(
          id: r['id'],
          clientId: userId,
          pickupLocation: LocationPoint(
            latitude: 12.3714,
            longitude: -1.5197,
            address: r['pickupAddress'],
          ),
          destinationLocation: LocationPoint(
            latitude: 12.3686,
            longitude: -1.5275,
            address: r['destinationAddress'],
          ),
          vehicleType: _vehicleType(r['vehicleType']),
          status: _status(r['status']),
          estimatedPrice: (r['price'] as num).toDouble(),
          distance: (r['distance'] as num).toDouble(),
          estimatedDuration: r['duration'],
          createdAt: r['date'],
          driverName: r['driverName'],
          finalPrice: (r['price'] as num).toDouble(),
        )).toList();
  }

  Future<void> acceptRide(
      String rideId, String driverId, Map<String, dynamic> info) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> startRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> completeRide(String rideId, double finalPrice) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> cancelRide(String rideId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  double calculateEstimatedPrice(double distanceKm, VehicleType vehicleType) =>
      MockDataService.calculatePrice(distanceKm, vehicleType);

  int calculateEstimatedDuration(double distanceKm) =>
      ((distanceKm / 30.0) * 60).round();

  VehicleType _vehicleType(String type) {
    switch (type) {
      case 'Comfort':
        return VehicleType.comfort;
      case 'Premium':
        return VehicleType.premium;
      case 'Van':
        return VehicleType.van;
      case 'Camion':
        return VehicleType.truck;
      default:
        return VehicleType.economy;
    }
  }

  RideStatus _status(String status) {
    switch (status) {
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      case 'inProgress':
        return RideStatus.inProgress;
      case 'accepted':
        return RideStatus.accepted;
      default:
        return RideStatus.pending;
    }
  }
}
