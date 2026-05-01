import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/mock_auth_service.dart';

class RegisterController extends GetxController {
  final MockAuthService _authService = Get.find<MockAuthService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedRole = 'client'.obs;
  final RxBool isLoading = false.obs;
  final RxBool acceptedTerms = false.obs;

  // Erreurs inline par champ
  final RxString nameError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmError = ''.obs;

  // Force du mot de passe : 0=vide, 1=faible, 2=moyen, 3=bon, 4=fort
  final RxInt passwordStrength = 0.obs;
  final RxBool passwordsMatch = false.obs;

  // Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();

  final RxBool isNameFocused = false.obs;
  final RxBool isPhoneFocused = false.obs;
  final RxBool isPasswordFocused = false.obs;
  final RxBool isConfirmFocused = false.obs;

  @override
  void onInit() {
    super.onInit();

    _setupFocusListeners();

    // Validation en temps réel
    nameController.addListener(() {
      if (nameError.value.isNotEmpty) nameError.value = '';
    });
    phoneController.addListener(() {
      if (phoneError.value.isNotEmpty) phoneError.value = '';
    });
    passwordController.addListener(() {
      _updatePasswordStrength(passwordController.text);
      _checkPasswordsMatch();
      if (passwordError.value.isNotEmpty) passwordError.value = '';
    });
    confirmPasswordController.addListener(() {
      _checkPasswordsMatch();
      if (confirmError.value.isNotEmpty) confirmError.value = '';
    });
  }

  void _setupFocusListeners() {
    nameFocus.addListener(() {
      isNameFocused.value = nameFocus.hasFocus;
      if (!nameFocus.hasFocus && nameController.text.isNotEmpty) _validateName();
    });
    phoneFocus.addListener(() {
      isPhoneFocused.value = phoneFocus.hasFocus;
      if (!phoneFocus.hasFocus && phoneController.text.isNotEmpty) _validatePhone();
    });
    passwordFocus.addListener(() {
      isPasswordFocused.value = passwordFocus.hasFocus;
      if (!passwordFocus.hasFocus && passwordController.text.isNotEmpty) _validatePassword();
    });
    confirmFocus.addListener(() {
      isConfirmFocused.value = confirmFocus.hasFocus;
      if (!confirmFocus.hasFocus && confirmPasswordController.text.isNotEmpty) _validateConfirm();
    });
  }

  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 0;
      return;
    }
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    passwordStrength.value = score.clamp(1, 4);
  }

  void _checkPasswordsMatch() {
    final p = passwordController.text;
    final c = confirmPasswordController.text;
    passwordsMatch.value = p.isNotEmpty && c.isNotEmpty && p == c;
  }

  bool _validateName() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      nameError.value = 'Veuillez entrer votre nom complet';
      return false;
    }
    if (name.length < 3) {
      nameError.value = 'Nom trop court (3 caractères minimum)';
      return false;
    }
    nameError.value = '';
    return true;
  }

  bool _validatePhone() {
    final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      phoneError.value = 'Veuillez entrer votre numéro';
      return false;
    }
    if (phone.length < 8) {
      phoneError.value = 'Numéro invalide (8 chiffres minimum)';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  bool _validatePassword() {
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      passwordError.value = 'Veuillez créer un mot de passe';
      return false;
    }
    if (password.length < 6) {
      passwordError.value = 'Minimum 6 caractères requis';
      return false;
    }
    passwordError.value = '';
    return true;
  }

  bool _validateConfirm() {
    final confirm = confirmPasswordController.text.trim();
    if (confirm.isEmpty) {
      confirmError.value = 'Veuillez confirmer le mot de passe';
      return false;
    }
    if (confirm != passwordController.text.trim()) {
      confirmError.value = 'Les mots de passe ne correspondent pas';
      return false;
    }
    confirmError.value = '';
    return true;
  }

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.value = !obscureConfirmPassword.value;
  void selectRole(String role) => selectedRole.value = role;
  void toggleTerms() => acceptedTerms.value = !acceptedTerms.value;

  Future<void> register() async {
    // Valider tous les champs
    final nameOk = _validateName();
    final phoneOk = _validatePhone();
    final passwordOk = _validatePassword();
    final confirmOk = _validateConfirm();

    if (!nameOk || !phoneOk || !passwordOk || !confirmOk) return;

    if (!acceptedTerms.value) {
      Fluttertoast.showToast(
        msg: 'Veuillez accepter les conditions d\'utilisation',
        backgroundColor: Colors.orange,
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await _authService.register(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole.value,
      );

      if (success) {
        // Naviguer directement vers la page home selon le rôle
        if (selectedRole.value == 'driver') {
          Get.offAllNamed('/driver/home');
        } else {
          Get.offAllNamed('/client/home');
        }
      } else {
        phoneError.value = 'Ce numéro est déjà utilisé';
        Fluttertoast.showToast(
          msg: 'Ce numéro est déjà associé à un compte',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'inscription. Réessayez.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.onClose();
  }
}
