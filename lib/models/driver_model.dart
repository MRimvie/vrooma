import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverStatus {
  offline,
  online,
  onRide,
  unavailable,
}

enum DocumentStatus {
  pending,
  approved,
  rejected,
}

class DriverModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? photoUrl;
  final DriverStatus status;
  final VehicleInfo vehicle;
  final DriverDocuments documents;
  final double rating;
  final int totalRides;
  final double totalEarnings;
  final double currentBalance;
  final LocationData? currentLocation;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final List<String> languages;
  final String? bankAccountNumber;
  final String? bankName;

  DriverModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.photoUrl,
    required this.status,
    required this.vehicle,
    required this.documents,
    this.rating = 5.0,
    this.totalRides = 0,
    this.totalEarnings = 0.0,
    this.currentBalance = 0.0,
    this.currentLocation,
    this.isVerified = false,
    required this.createdAt,
    this.lastActiveAt,
    this.languages = const ['fr'],
    this.bankAccountNumber,
    this.bankName,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      status: DriverStatus.values.firstWhere(
        (e) => e.toString() == 'DriverStatus.${json['status']}',
        orElse: () => DriverStatus.offline,
      ),
      vehicle: VehicleInfo.fromJson(json['vehicle'] ?? {}),
      documents: DriverDocuments.fromJson(json['documents'] ?? {}),
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalRides: json['totalRides'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      currentLocation: json['currentLocation'] != null
          ? LocationData.fromJson(json['currentLocation'])
          : null,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null
          ? (json['lastActiveAt'] is Timestamp
              ? (json['lastActiveAt'] as Timestamp).toDate()
              : DateTime.parse(json['lastActiveAt']))
          : null,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : ['fr'],
      bankAccountNumber: json['bankAccountNumber'],
      bankName: json['bankName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
      'vehicle': vehicle.toJson(),
      'documents': documents.toJson(),
      'rating': rating,
      'totalRides': totalRides,
      'totalEarnings': totalEarnings,
      'currentBalance': currentBalance,
      'currentLocation': currentLocation?.toJson(),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'languages': languages,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
    };
  }
}

class VehicleInfo {
  final String type;
  final String brand;
  final String model;
  final String year;
  final String color;
  final String plateNumber;
  final int capacity;
  final String? photoUrl;

  VehicleInfo({
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    this.capacity = 4,
    this.photoUrl,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      type: json['type'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      color: json['color'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      capacity: json['capacity'] ?? 4,
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plateNumber': plateNumber,
      'capacity': capacity,
      'photoUrl': photoUrl,
    };
  }
}

class DriverDocuments {
  final DocumentInfo? driverLicense;
  final DocumentInfo? vehicleRegistration;
  final DocumentInfo? insurance;
  final DocumentInfo? identityCard;
  final DocumentInfo? criminalRecord;

  DriverDocuments({
    this.driverLicense,
    this.vehicleRegistration,
    this.insurance,
    this.identityCard,
    this.criminalRecord,
  });

  factory DriverDocuments.fromJson(Map<String, dynamic> json) {
    return DriverDocuments(
      driverLicense: json['driverLicense'] != null
          ? DocumentInfo.fromJson(json['driverLicense'])
          : null,
      vehicleRegistration: json['vehicleRegistration'] != null
          ? DocumentInfo.fromJson(json['vehicleRegistration'])
          : null,
      insurance: json['insurance'] != null
          ? DocumentInfo.fromJson(json['insurance'])
          : null,
      identityCard: json['identityCard'] != null
          ? DocumentInfo.fromJson(json['identityCard'])
          : null,
      criminalRecord: json['criminalRecord'] != null
          ? DocumentInfo.fromJson(json['criminalRecord'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverLicense': driverLicense?.toJson(),
      'vehicleRegistration': vehicleRegistration?.toJson(),
      'insurance': insurance?.toJson(),
      'identityCard': identityCard?.toJson(),
      'criminalRecord': criminalRecord?.toJson(),
    };
  }
}

class DocumentInfo {
  final String url;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final DateTime? expiryDate;
  final String? rejectionReason;

  DocumentInfo({
    required this.url,
    required this.status,
    required this.uploadedAt,
    this.expiryDate,
    this.rejectionReason,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      url: json['url'] ?? '',
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == 'DocumentStatus.${json['status']}',
        orElse: () => DocumentStatus.pending,
      ),
      uploadedAt: json['uploadedAt'] is Timestamp
          ? (json['uploadedAt'] as Timestamp).toDate()
          : DateTime.parse(json['uploadedAt']),
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] is Timestamp
              ? (json['expiryDate'] as Timestamp).toDate()
              : DateTime.parse(json['expiryDate']))
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'status': status.toString().split('.').last,
      'uploadedAt': uploadedAt.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double? heading;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.heading,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      heading: json['heading']?.toDouble(),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
