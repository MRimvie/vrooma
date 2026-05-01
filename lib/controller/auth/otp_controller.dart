import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/mock_auth_service.dart';

class OTPController extends GetxController {
  final MockAuthService _authService = Get.find<MockAuthService>();
  
  final TextEditingController otpController = TextEditingController();
  final RxString otpError = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool canResend = false.obs;
  final RxInt resendTimer = 60.obs;
  
  late String verificationId;
  String phoneNumber = '';
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    verificationId = args['verificationId'];
    phoneNumber = args['phoneNumber'];
    startResendTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    if (!otpController.hasListeners) {
      otpController.dispose();
    }
    super.onClose();
  }

  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void validateOTP() {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      otpError.value = 'Veuillez entrer le code OTP';
      return;
    }
    if (otp.length < 6) {
      otpError.value = 'Code OTP invalide';
      return;
    }
    otpError.value = '';
  }

  Future<void> verifyOTP() async {
    validateOTP();
    if (otpError.value.isNotEmpty) return;

    isLoading.value = true;
    try {
      final isValid = await _authService.verifyOTP(
        verificationId,
        otpController.text.trim(),
      );

      if (isValid) {
        final userId = _authService.currentUserId ?? 'mock_user_id';
        final userData = await _authService.getUserData(userId);

        if (userData != null) {
          _authService.saveUserLocally(userData);
          final role = userData['role'];
          if (role == 'driver') {
            Get.offAllNamed('/driver/home');
          } else {
            Get.offAllNamed('/client/home');
          }
        }
      } else {
        otpError.value = 'Code OTP invalide (utilisez 123456)';
        Fluttertoast.showToast(
          msg: 'Code OTP invalide (utilisez 123456 pour tester)',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      otpError.value = 'Code OTP invalide';
      Fluttertoast.showToast(
        msg: 'Code OTP invalide',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    try {
      await _authService.sendOTP(
        phoneNumber,
        onCodeSent: (newVerificationId) {
          verificationId = newVerificationId;
          startResendTimer();
          Fluttertoast.showToast(
            msg: 'Code renvoyé avec succès',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        },
        onError: (error) {
          Fluttertoast.showToast(
            msg: error,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors du renvoi du code',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
