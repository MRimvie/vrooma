import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../../helpers/services/location_service.dart';
import '../../services/mock_ride_service.dart';
import '../../services/mock_auth_service.dart';
import '../../widgets/bottom_bar/navigation_provider.dart';
import '../../models/ride_model.dart';

class HomeMapController extends GetxController {
  final LocationService _locationService = LocationService();
  final MockRideService _rideService = Get.find<MockRideService>();
  final MockAuthService _authService = Get.find<MockAuthService>();

  MapController? mapController;
  final LatLng initialPosition = const LatLng(12.3714, -1.5197);

  final RxList<Marker> markers = <Marker>[].obs;
  final RxList<Polyline> polylines = <Polyline>[].obs;
  final RxString currentAddress = 'Chargement...'.obs;
  final RxDouble bottomSheetHeight = 0.0.obs;
  final RxBool isSelectingDestination = true.obs;
  final RxBool isSelectingOnMap = false.obs;
  final RxString selectionMode = 'pickup'.obs;
  final RxBool isLoading = false.obs;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  LatLng? pickupLocation;
  LatLng? destinationLocation;

  final RxList<Map<String, dynamic>> recentLocations = <Map<String, dynamic>>[
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
  ].obs;

  final RxList<Map<String, dynamic>> vehicleTypes = <Map<String, dynamic>>[
    {
      'type': 0,
      'name': 'Economy',
      'description': 'Abordable et confortable',
      'icon': Icons.directions_car,
      'capacity': 4,
      'price': 0,
    },
    {
      'type': 1,
      'name': 'Comfort',
      'description': 'Plus d\'espace et de confort',
      'icon': Icons.directions_car_filled,
      'capacity': 4,
      'price': 0,
    },
    {
      'type': 2,
      'name': 'Premium',
      'description': 'Véhicules haut de gamme',
      'icon': Icons.car_rental,
      'capacity': 4,
      'price': 0,
    },
    {
      'type': 3,
      'name': 'Van',
      'description': 'Pour groupes ou bagages',
      'icon': Icons.airport_shuttle,
      'capacity': 6,
      'price': 0,
    },
    {
      'type': 4,
      'name': 'Camion',
      'description': 'Transport de marchandises',
      'icon': Icons.local_shipping,
      'capacity': 2,
      'price': 0,
    },
  ].obs;

  final RxInt selectedVehicleType = 0.obs;
  final RxDouble distance = 0.0.obs;
  final RxInt duration = 0.obs;
  final RxString appliedPromoCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Désactivé temporairement pour éviter les crashs de permissions
    // _getCurrentLocation();
    _setDefaultLocation();
  }

  void _setDefaultLocation() {
    currentAddress.value = 'Ouagadougou, Burkina Faso';
    pickupLocation = const LatLng(12.3714, -1.5197);
    pickupController.text = 'Gounghin, Ouagadougou';

    _addMarker(
      'pickup',
      pickupLocation!,
      'Votre position',
      Colors.green,
    );
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        currentAddress.value = address;
        pickupLocation = LatLng(position.latitude, position.longitude);
        pickupController.text = address;

        mapController?.move(
          LatLng(position.latitude, position.longitude),
          14.0,
        );

        _addMarker(
          'pickup',
          LatLng(position.latitude, position.longitude),
          'Point de départ',
          Colors.green,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Impossible d\'obtenir votre position',
        backgroundColor: Colors.red,
      );
    }
  }

  void onMapCreated(MapController controller) {
    mapController = controller;
  }

  void onMapTap(LatLng point) async {
    if (!isSelectingOnMap.value) return;

    try {
      final address = await _locationService.getAddressFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (selectionMode.value == 'pickup') {
        pickupLocation = point;
        pickupController.text = address;
        _addMarker('pickup', point, 'Point de départ', Colors.green);

        Fluttertoast.showToast(
          msg: 'Point de départ sélectionné',
          backgroundColor: Colors.green,
        );

        isSelectingOnMap.value = false;
        bottomSheetHeight.value = 300;
      } else if (selectionMode.value == 'destination') {
        destinationLocation = point;
        destinationController.text = address;
        _addMarker('destination', point, 'Destination', Colors.red);

        Fluttertoast.showToast(
          msg: 'Destination sélectionnée',
          backgroundColor: Colors.green,
        );

        if (pickupLocation != null) {
          await _calculateRoute();
          isSelectingDestination.value = false;
          bottomSheetHeight.value = 500;
        }

        isSelectingOnMap.value = false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la récupération de l\'adresse',
        backgroundColor: Colors.red,
      );
    }
  }

  void onDragUpdate(DragUpdateDetails details) {
    final newHeight = bottomSheetHeight.value - details.delta.dy;
    if (newHeight >= 60 && newHeight <= 600) {
      bottomSheetHeight.value = newHeight;
    }
  }

  Future<void> goToCurrentLocation() async {
    // Retour à la position par défaut
    mapController?.move(const LatLng(12.3714, -1.5197), 14.0);
    Fluttertoast.showToast(
      msg: 'Position: Ouagadougou',
      backgroundColor: Colors.blue,
    );
  }

  void openDrawer() {
    // Navigation vers le profil via le bottom nav
    final navProvider = Get.find<NavigationProvider>();
    navProvider.goToProfile();
  }

  void enableMapSelection(String mode) {
    selectionMode.value = mode;
    isSelectingOnMap.value = true;
    bottomSheetHeight.value = 0;

    Fluttertoast.showToast(
      msg: mode == 'pickup'
          ? 'Touchez la carte pour sélectionner le point de départ'
          : 'Touchez la carte pour sélectionner la destination',
      backgroundColor: Colors.blue,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<void> selectPickupLocation() async {
    final result = await Get.toNamed('/search-location', arguments: {
      'title': 'Point de départ',
    });
    if (result != null) {
      pickupLocation = LatLng(result['lat'], result['lng']);
      pickupController.text = result['address'];
      _addMarker(
        'pickup',
        pickupLocation!,
        'Point de départ',
        Colors.green,
      );
      mapController?.move(pickupLocation!, 14.0);
    }
  }

  Future<void> selectDestination() async {
    print('📋 selectDestination appelée');
    print('Hauteur avant: ${bottomSheetHeight.value}');
    // Ouvre le bottom sheet pour la sélection
    bottomSheetHeight.value = 400;
    print('Hauteur après: ${bottomSheetHeight.value}');
  }

  Future<void> selectDestinationFromSearch() async {
    final result = await Get.toNamed('/search-location', arguments: {
      'title': 'Destination',
    });
    if (result != null) {
      destinationLocation = LatLng(result['lat'], result['lng']);
      destinationController.text = result['address'];
      _addMarker(
        'destination',
        destinationLocation!,
        'Destination',
        Colors.red,
      );

      if (pickupLocation != null) {
        await _calculateRoute();
        isSelectingDestination.value = false;
        bottomSheetHeight.value = 500;
      }
    }
  }

  void selectRecentLocation(Map<String, dynamic> location) {
    destinationLocation = LatLng(location['lat'], location['lng']);
    destinationController.text = location['address'];
    _addMarker(
      'destination',
      destinationLocation!,
      location['name'],
      Colors.red,
    );

    if (pickupLocation != null) {
      _calculateRoute();
      isSelectingDestination.value = false;
      bottomSheetHeight.value = 500;
    }
  }

  void _addMarker(String id, LatLng position, String title, Color color) {
    markers.removeWhere((m) => m.point == position);
    markers.add(
      Marker(
        point: position,
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_on,
          color: color,
          size: 40,
        ),
      ),
    );
  }

  Future<void> _calculateRoute() async {
    if (pickupLocation == null || destinationLocation == null) return;

    distance.value = await _locationService.calculateDistanceInKm(
      pickupLocation!.latitude,
      pickupLocation!.longitude,
      destinationLocation!.latitude,
      destinationLocation!.longitude,
    );
    duration.value = _rideService.calculateEstimatedDuration(distance.value);

    for (var i = 0; i < vehicleTypes.length; i++) {
      final price = _rideService.calculateEstimatedPrice(
        distance.value,
        VehicleType.values[i],
      );
      vehicleTypes[i]['price'] = price.round();
    }

    polylines.add(
      Polyline(
        points: [pickupLocation!, destinationLocation!],
        color: Colors.blue,
        strokeWidth: 4.0,
      ),
    );

    final bounds = LatLngBounds(
      pickupLocation!,
      destinationLocation!,
    );

    mapController?.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void selectVehicleType(int type) {
    selectedVehicleType.value = type;
  }

  Future<void> showPromoCodeDialog() async {
    final TextEditingController promoController = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Code promo'),
        content: TextField(
          controller: promoController,
          decoration: const InputDecoration(
            hintText: 'Entrez votre code promo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              appliedPromoCode.value = promoController.text;
              Get.back();
              Fluttertoast.showToast(
                msg: 'Code promo appliqué',
                backgroundColor: Colors.green,
              );
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmRide() async {
    if (pickupLocation == null || destinationLocation == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez sélectionner un point de départ et une destination',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final selectedVehicle = vehicleTypes[selectedVehicleType.value];
      final estimatedPrice = selectedVehicle['price'].toDouble();

      final ride = RideModel(
        id: const Uuid().v4(),
        clientId: userId,
        pickupLocation: LocationPoint(
          latitude: pickupLocation!.latitude,
          longitude: pickupLocation!.longitude,
          address: pickupController.text,
        ),
        destinationLocation: LocationPoint(
          latitude: destinationLocation!.latitude,
          longitude: destinationLocation!.longitude,
          address: destinationController.text,
        ),
        vehicleType: VehicleType.values[selectedVehicleType.value],
        status: RideStatus.pending,
        estimatedPrice: estimatedPrice,
        distance: distance.value,
        estimatedDuration: duration.value,
        createdAt: DateTime.now(),
        promoCode:
            appliedPromoCode.value.isEmpty ? null : appliedPromoCode.value,
      );

      final rideId = await _rideService.createRide(ride);

      Get.offNamed('/ride-tracking', arguments: {
        'rideId': rideId,
        'pickupLat': pickupLocation!.latitude,
        'pickupLng': pickupLocation!.longitude,
        'destinationLat': destinationLocation!.latitude,
        'destinationLng': destinationLocation!.longitude,
        'pickupAddress': pickupController.text,
        'destinationAddress': destinationController.text,
      });

      Fluttertoast.showToast(
        msg: 'Recherche d\'un chauffeur...',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la création de la course',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
