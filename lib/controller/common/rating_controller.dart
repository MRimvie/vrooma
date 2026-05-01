import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RatingController extends GetxController {

  final TextEditingController commentController = TextEditingController();
  final RxDouble rating = 5.0.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString driverName = 'Chauffeur'.obs;
  final RxString driverPhoto = ''.obs;

  final RxList<String> availableTags = <String>[
    'Conduite sécurisée',
    'Véhicule propre',
    'Ponctuel',
    'Courtois',
    'Trajet rapide',
    'Bon itinéraire',
  ].obs;

  late String rideId;
  late String driverId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    rideId = args['rideId'] ?? '';
    driverId = args['driverId'] ?? '';
    driverName.value = args['driverName'] ?? 'Chauffeur';
    driverPhoto.value = args['driverPhoto'] ?? '';
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  Future<void> submitRating() async {
    if (rating.value < 1) {
      Fluttertoast.showToast(
        msg: 'Veuillez donner une note',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      print('⭐ Mock: Évaluation soumise - ${rating.value}/5 pour $driverId');

      Fluttertoast.showToast(
        msg: 'Merci pour votre évaluation !',
        backgroundColor: Colors.green,
      );

      Get.offAllNamed('/client/home');
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'envoi de l\'évaluation',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
