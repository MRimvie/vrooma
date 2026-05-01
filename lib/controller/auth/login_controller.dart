import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/mock_auth_service.dart';

class LoginController extends GetxController {
  final MockAuthService _authService = Get.find<MockAuthService>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  // Inline field errors
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;

  // Focus tracking for animated borders
  final RxBool isPhoneFocused = false.obs;
  final RxBool isPasswordFocused = false.obs;

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    phoneFocusNode.addListener(() {
      isPhoneFocused.value = phoneFocusNode.hasFocus;
      // Valider quand on quitte le champ
      if (!phoneFocusNode.hasFocus && phoneController.text.isNotEmpty) {
        _validatePhoneField();
      }
    });

    passwordFocusNode.addListener(() {
      isPasswordFocused.value = passwordFocusNode.hasFocus;
      if (!passwordFocusNode.hasFocus && passwordController.text.isNotEmpty) {
        _validatePasswordField();
      }
    });

    // Effacer les erreurs dès que l'utilisateur retape
    phoneController.addListener(() {
      if (phoneError.value.isNotEmpty) phoneError.value = '';
    });
    passwordController.addListener(() {
      if (passwordError.value.isNotEmpty) passwordError.value = '';
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  bool _validatePhoneField() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = 'Veuillez entrer votre numéro de téléphone';
      return false;
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      phoneError.value = 'Numéro invalide (8 chiffres minimum)';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  bool _validatePasswordField() {
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      passwordError.value = 'Veuillez entrer votre mot de passe';
      return false;
    }
    if (password.length < 6) {
      passwordError.value = 'Le mot de passe est trop court';
      return false;
    }
    passwordError.value = '';
    return true;
  }

  Future<void> login() async {
    final phoneOk = _validatePhoneField();
    final passwordOk = _validatePasswordField();
    if (!phoneOk || !passwordOk) return;

    isLoading.value = true;

    try {
      final success = await _authService.loginWithPassword(
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        rememberMe: rememberMe.value,
      );

      if (success) {
        final userRole = _authService.currentUserRole;
        if (userRole == 'driver') {
          Get.offAllNamed('/driver/home');
        } else {
          Get.offAllNamed('/client/home');
        }
      } else {
        phoneError.value = 'Numéro ou mot de passe incorrect';
        passwordError.value = ' '; // espace pour afficher le rouge sur le champ
        Fluttertoast.showToast(
          msg: 'Numéro ou mot de passe incorrect',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur de connexion. Réessayez.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
