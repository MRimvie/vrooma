import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/ride_model.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createRide(RideModel ride) async {
    try {
      final rideId = _uuid.v4();
      final rideData = ride.copyWith(id: rideId).toJson();
      await _firestore.collection('rides').doc(rideId).set(rideData);
      return rideId;
    } catch (e) {
      throw Exception('Erreur lors de la création de la course');
    }
  }

  Future<void> updateRide(String rideId, Map<String, dynamic> updates) async {
    await _firestore.collection('rides').doc(rideId).update(updates);
  }

  Future<RideModel?> getRide(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return RideModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<RideModel?> getRideStream(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((doc) {
      if (doc.exists) {
        return RideModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Future<List<RideModel>> getUserRides(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('clientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RideModel>> getDriverRides(String driverId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<RideModel>> getPendingRidesStream() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> acceptRide(String rideId, String driverId, Map<String, dynamic> driverInfo) async {
    await _firestore.collection('rides').doc(rideId).update({
      'driverId': driverId,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'driverName': driverInfo['name'],
      'driverPhone': driverInfo['phone'],
      'driverVehicle': driverInfo['vehicle'],
      'driverPlateNumber': driverInfo['plateNumber'],
      'driverRating': driverInfo['rating'],
    });
  }

  Future<void> startRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'inProgress',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeRide(String rideId, double finalPrice) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'finalPrice': finalPrice,
    });
  }

  Future<void> cancelRide(String rideId, String reason) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
      'cancelReason': reason,
    });
  }

  double calculateEstimatedPrice(double distance, VehicleType vehicleType) {
    const baseFare = 500.0;
    final pricePerKm = {
      VehicleType.economy: 250.0,
      VehicleType.comfort: 350.0,
      VehicleType.premium: 500.0,
      VehicleType.van: 400.0,
      VehicleType.truck: 600.0,
    };

    final kmPrice = pricePerKm[vehicleType] ?? 250.0;
    return baseFare + (distance * kmPrice);
  }

  int calculateEstimatedDuration(double distance) {
    const averageSpeedKmh = 40.0;
    return ((distance / averageSpeedKmh) * 60).round();
  }
}
