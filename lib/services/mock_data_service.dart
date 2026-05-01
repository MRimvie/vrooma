import '../models/ride_model.dart';
import '../models/driver_model.dart';

class MockDataService {
  static List<Map<String, dynamic>> getMockDrivers() {
    return [
      {
        'id': 'driver_1',
        'name': 'Ousmane Kaboré',
        'phone': '+22670111111',
        'rating': 4.8,
        'vehicle': 'Toyota Corolla',
        'plateNumber': 'BF 1234 AA',
        'photo': 'https://i.pravatar.cc/150?img=12',
        'latitude': 12.3714,
        'longitude': -1.5197,
      },
      {
        'id': 'driver_2',
        'name': 'Fatou Sawadogo',
        'phone': '+22670222222',
        'rating': 4.9,
        'vehicle': 'Honda Civic',
        'plateNumber': 'BF 5678 BB',
        'photo': 'https://i.pravatar.cc/150?img=45',
        'latitude': 12.3750,
        'longitude': -1.5180,
      },
      {
        'id': 'driver_3',
        'name': 'Ibrahim Ouédraogo',
        'phone': '+22670333333',
        'rating': 4.7,
        'vehicle': 'Nissan Sentra',
        'plateNumber': 'BF 9012 CC',
        'photo': 'https://i.pravatar.cc/150?img=33',
        'latitude': 12.3680,
        'longitude': -1.5220,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockRides() {
    return [
      {
        'id': 'ride_1',
        'pickupAddress': 'Avenue Kwame Nkrumah, Ouagadougou',
        'destinationAddress': 'Université de Ouagadougou',
        'distance': 5.2,
        'duration': 15,
        'price': 2500,
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'driverName': 'Ousmane Kaboré',
        'vehicleType': 'Economy',
      },
      {
        'id': 'ride_2',
        'pickupAddress': 'Marché Central, Ouagadougou',
        'destinationAddress': 'Aéroport de Ouagadougou',
        'distance': 8.5,
        'duration': 25,
        'price': 4000,
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'driverName': 'Fatou Sawadogo',
        'vehicleType': 'Comfort',
      },
      {
        'id': 'ride_3',
        'pickupAddress': 'Zone du Bois, Ouagadougou',
        'destinationAddress': 'Hôpital Yalgado Ouédraogo',
        'distance': 3.8,
        'duration': 12,
        'price': 2000,
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'driverName': 'Ibrahim Ouédraogo',
        'vehicleType': 'Economy',
      },
    ];
  }

  static List<Map<String, dynamic>> getMockLocations() {
    return [
      {
        'name': 'Maison',
        'address': 'Gounghin, Ouagadougou',
        'lat': 12.3714,
        'lng': -1.5197,
      },
      {
        'name': 'Bureau',
        'address': 'Avenue Kwame Nkrumah, Ouagadougou',
        'lat': 12.3686,
        'lng': -1.5275,
      },
      {
        'name': 'Université',
        'address': 'Université de Ouagadougou',
        'lat': 12.4011,
        'lng': -1.4760,
      },
      {
        'name': 'Aéroport',
        'address': 'Aéroport International de Ouagadougou',
        'lat': 12.3532,
        'lng': -1.5124,
      },
      {
        'name': 'Marché Central',
        'address': 'Grand Marché, Ouagadougou',
        'lat': 12.3658,
        'lng': -1.5339,
      },
    ];
  }

  static Map<String, dynamic> getMockPromoCode(String code) {
    final promoCodes = {
      'BIENVENUE': {
        'code': 'BIENVENUE',
        'description': 'Réduction de 50% sur votre première course',
        'type': 'percentage',
        'value': 50.0,
        'maxDiscount': 2000.0,
      },
      'BF2026': {
        'code': 'BF2026',
        'description': 'Réduction de 1000 FCFA',
        'type': 'fixed',
        'value': 1000.0,
      },
      'WEEKEND': {
        'code': 'WEEKEND',
        'description': 'Réduction de 20% le weekend',
        'type': 'percentage',
        'value': 20.0,
        'maxDiscount': 1500.0,
      },
    };

    return promoCodes[code.toUpperCase()] ?? {};
  }

  static List<String> getPopularDestinations() {
    return [
      'Aéroport International de Ouagadougou',
      'Université de Ouagadougou',
      'Grand Marché',
      'Hôpital Yalgado Ouédraogo',
      'Stade du 4-Août',
      'Place des Cinéastes',
      'Gare Routière',
      'Zone du Bois',
      'Gounghin',
      'Ouaga 2000',
    ];
  }

  static double calculatePrice(double distance, VehicleType vehicleType) {
    const baseFare = 500.0;
    final pricePerKm = {
      VehicleType.economy: 300.0,
      VehicleType.comfort: 450.0,
      VehicleType.premium: 600.0,
      VehicleType.van: 500.0,
      VehicleType.truck: 700.0,
    };

    final kmPrice = pricePerKm[vehicleType] ?? 300.0;
    return baseFare + (distance * kmPrice);
  }
}
