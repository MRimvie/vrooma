import 'package:cloud_firestore/cloud_firestore.dart';

enum PromoType {
  percentage,
  fixed,
  freeRide,
}

enum PromoStatus {
  active,
  expired,
  disabled,
}

class PromoCodeModel {
  final String id;
  final String code;
  final String description;
  final PromoType type;
  final double value;
  final double? maxDiscount;
  final double? minRideAmount;
  final PromoStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int maxUsagePerUser;
  final int totalUsageLimit;
  final int currentUsageCount;
  final List<String>? applicableVehicleTypes;
  final List<String>? applicableUserIds;
  final bool isFirstRideOnly;
  final DateTime createdAt;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minRideAmount,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.maxUsagePerUser = 1,
    this.totalUsageLimit = 1000,
    this.currentUsageCount = 0,
    this.applicableVehicleTypes,
    this.applicableUserIds,
    this.isFirstRideOnly = false,
    required this.createdAt,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      type: PromoType.values.firstWhere(
        (e) => e.toString() == 'PromoType.${json['type']}',
        orElse: () => PromoType.percentage,
      ),
      value: (json['value'] ?? 0).toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      minRideAmount: json['minRideAmount']?.toDouble(),
      status: PromoStatus.values.firstWhere(
        (e) => e.toString() == 'PromoStatus.${json['status']}',
        orElse: () => PromoStatus.active,
      ),
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.parse(json['startDate']),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.parse(json['endDate']),
      maxUsagePerUser: json['maxUsagePerUser'] ?? 1,
      totalUsageLimit: json['totalUsageLimit'] ?? 1000,
      currentUsageCount: json['currentUsageCount'] ?? 0,
      applicableVehicleTypes: json['applicableVehicleTypes'] != null
          ? List<String>.from(json['applicableVehicleTypes'])
          : null,
      applicableUserIds: json['applicableUserIds'] != null
          ? List<String>.from(json['applicableUserIds'])
          : null,
      isFirstRideOnly: json['isFirstRideOnly'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'maxDiscount': maxDiscount,
      'minRideAmount': minRideAmount,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxUsagePerUser': maxUsagePerUser,
      'totalUsageLimit': totalUsageLimit,
      'currentUsageCount': currentUsageCount,
      'applicableVehicleTypes': applicableVehicleTypes,
      'applicableUserIds': applicableUserIds,
      'isFirstRideOnly': isFirstRideOnly,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool isValid() {
    final now = DateTime.now();
    return status == PromoStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        currentUsageCount < totalUsageLimit;
  }

  double calculateDiscount(double rideAmount) {
    if (!isValid()) return 0.0;
    if (minRideAmount != null && rideAmount < minRideAmount!) return 0.0;

    double discount = 0.0;
    switch (type) {
      case PromoType.percentage:
        discount = rideAmount * (value / 100);
        if (maxDiscount != null && discount > maxDiscount!) {
          discount = maxDiscount!;
        }
        break;
      case PromoType.fixed:
        discount = value;
        break;
      case PromoType.freeRide:
        discount = rideAmount;
        if (maxDiscount != null && discount > maxDiscount!) {
          discount = maxDiscount!;
        }
        break;
    }
    return discount;
  }
}

class PromoUsageModel {
  final String id;
  final String promoCodeId;
  final String userId;
  final String rideId;
  final double discountAmount;
  final DateTime usedAt;

  PromoUsageModel({
    required this.id,
    required this.promoCodeId,
    required this.userId,
    required this.rideId,
    required this.discountAmount,
    required this.usedAt,
  });

  factory PromoUsageModel.fromJson(Map<String, dynamic> json) {
    return PromoUsageModel(
      id: json['id'] ?? '',
      promoCodeId: json['promoCodeId'] ?? '',
      userId: json['userId'] ?? '',
      rideId: json['rideId'] ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      usedAt: json['usedAt'] is Timestamp
          ? (json['usedAt'] as Timestamp).toDate()
          : DateTime.parse(json['usedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promoCodeId': promoCodeId,
      'userId': userId,
      'rideId': rideId,
      'discountAmount': discountAmount,
      'usedAt': usedAt.toIso8601String(),
    };
  }
}
