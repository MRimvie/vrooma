import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/mock_auth_service.dart';

class PhoneAuthController extends GetxController {
  final MockAuthService _authService = MockAuthService();
  
  final TextEditingController phoneController = TextEditingController();
  final RxString phoneError = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = 'Veuillez entrer votre numéro de téléphone';
      return;
    }
    if (phone.length < 9) {
      phoneError.value = 'Numéro de téléphone invalide';
      return;
    }
    phoneError.value = '';
  }

  Future<void> sendOTP() async {
    validatePhone();
    if (phoneError.value.isNotEmpty) return;

    isLoading.value = true;
    final phone = '+226${phoneController.text.trim()}';

    try {
      await _authService.sendOTP(
        phone,
        onCodeSent: (verificationId) {
          isLoading.value = false;
          Get.toNamed('/auth/otp', arguments: {
            'verificationId': verificationId,
            'phoneNumber': phone,
          });
        },
        onError: (error) {
          isLoading.value = false;
          Fluttertoast.showToast(
            msg: error,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        },
      );
    } catch (e) {
      isLoading.value = false;
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'envoi du code',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
