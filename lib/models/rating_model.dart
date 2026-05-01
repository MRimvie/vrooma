import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String rideId;
  final String clientId;
  final String driverId;
  final double rating;
  final String? comment;
  final List<String> tags;
  final DateTime createdAt;
  final bool isDriverRating;

  RatingModel({
    required this.id,
    required this.rideId,
    required this.clientId,
    required this.driverId,
    required this.rating,
    this.comment,
    this.tags = const [],
    required this.createdAt,
    this.isDriverRating = false,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] ?? '',
      rideId: json['rideId'] ?? '',
      clientId: json['clientId'] ?? '',
      driverId: json['driverId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      isDriverRating: json['isDriverRating'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'clientId': clientId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isDriverRating': isDriverRating,
    };
  }
}

class RatingTag {
  static const List<String> positiveDriverTags = [
    'Conduite sécurisée',
    'Véhicule propre',
    'Ponctuel',
    'Courtois',
    'Trajet rapide',
    'Bon itinéraire',
  ];

  static const List<String> negativeDriverTags = [
    'Conduite dangereuse',
    'Véhicule sale',
    'En retard',
    'Impoli',
    'Trajet lent',
    'Mauvais itinéraire',
  ];

  static const List<String> positiveClientTags = [
    'Respectueux',
    'Ponctuel',
    'Bon communicant',
    'Propre',
  ];

  static const List<String> negativeClientTags = [
    'Impoli',
    'En retard',
    'Mauvaise communication',
    'Comportement inapproprié',
  ];
}
