import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> sendResetCode() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Veuillez entrer votre numéro de téléphone',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      Fluttertoast.showToast(
        msg: 'Un code de réinitialisation a été envoyé au $phone',
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'envoi du code',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
