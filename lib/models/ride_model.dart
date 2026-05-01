import 'package:cloud_firestore/cloud_firestore.dart';

enum RideStatus {
  pending,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

enum VehicleType {
  economy,
  comfort,
  premium,
  van,
  truck,
}

class RideModel {
  final String id;
  final String clientId;
  final String? driverId;
  final LocationPoint pickupLocation;
  final LocationPoint destinationLocation;
  final VehicleType vehicleType;
  final RideStatus status;
  final double estimatedPrice;
  final double? finalPrice;
  final double distance;
  final int estimatedDuration;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? cancelReason;
  final String? clientName;
  final String? clientPhone;
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String? driverPlateNumber;
  final double? driverRating;
  final String? promoCode;
  final double? discount;
  final String? paymentMethod;
  final bool isPaidFor;
  final String? notes;
  final List<LocationPoint>? route;

  RideModel({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.vehicleType,
    required this.status,
    required this.estimatedPrice,
    this.finalPrice,
    required this.distance,
    required this.estimatedDuration,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelReason,
    this.clientName,
    this.clientPhone,
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    this.driverPlateNumber,
    this.driverRating,
    this.promoCode,
    this.discount,
    this.paymentMethod,
    this.isPaidFor = false,
    this.notes,
    this.route,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      driverId: json['driverId'],
      pickupLocation: LocationPoint.fromJson(json['pickupLocation']),
      destinationLocation: LocationPoint.fromJson(json['destinationLocation']),
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.toString() == 'VehicleType.${json['vehicleType']}',
        orElse: () => VehicleType.economy,
      ),
      status: RideStatus.values.firstWhere(
        (e) => e.toString() == 'RideStatus.${json['status']}',
        orElse: () => RideStatus.pending,
      ),
      estimatedPrice: (json['estimatedPrice'] ?? 0).toDouble(),
      finalPrice: json['finalPrice']?.toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null
          ? (json['acceptedAt'] is Timestamp
              ? (json['acceptedAt'] as Timestamp).toDate()
              : DateTime.parse(json['acceptedAt']))
          : null,
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] is Timestamp
              ? (json['startedAt'] as Timestamp).toDate()
              : DateTime.parse(json['startedAt']))
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt']))
          : null,
      cancelReason: json['cancelReason'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverVehicle: json['driverVehicle'],
      driverPlateNumber: json['driverPlateNumber'],
      driverRating: json['driverRating']?.toDouble(),
      promoCode: json['promoCode'],
      discount: json['discount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      isPaidFor: json['isPaidFor'] ?? false,
      notes: json['notes'],
      route: json['route'] != null
          ? (json['route'] as List).map((e) => LocationPoint.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'driverId': driverId,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'vehicleType': vehicleType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverVehicle': driverVehicle,
      'driverPlateNumber': driverPlateNumber,
      'driverRating': driverRating,
      'promoCode': promoCode,
      'discount': discount,
      'paymentMethod': paymentMethod,
      'isPaidFor': isPaidFor,
      'notes': notes,
      'route': route?.map((e) => e.toJson()).toList(),
    };
  }

  RideModel copyWith({
    String? id,
    String? clientId,
    String? driverId,
    LocationPoint? pickupLocation,
    LocationPoint? destinationLocation,
    VehicleType? vehicleType,
    RideStatus? status,
    double? estimatedPrice,
    double? finalPrice,
    double? distance,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? cancelReason,
    String? clientName,
    String? clientPhone,
    String? driverName,
    String? driverPhone,
    String? driverVehicle,
    String? driverPlateNumber,
    double? driverRating,
    String? promoCode,
    double? discount,
    String? paymentMethod,
    bool? isPaidFor,
    String? notes,
    List<LocationPoint>? route,
  }) {
    return RideModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelReason: cancelReason ?? this.cancelReason,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverPlateNumber: driverPlateNumber ?? this.driverPlateNumber,
      driverRating: driverRating ?? this.driverRating,
      promoCode: promoCode ?? this.promoCode,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaidFor: isPaidFor ?? this.isPaidFor,
      notes: notes ?? this.notes,
      route: route ?? this.route,
    );
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeName;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeName,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      placeName: json['placeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeName': placeName,
    };
  }
}
