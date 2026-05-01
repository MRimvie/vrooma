import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/payment_model.dart';

class PaymentController extends GetxController {
  final RxDouble amount = 0.0.obs;
  final RxDouble walletBalance = 5000.0.obs;
  final Rx<PaymentMethod> selectedMethod = PaymentMethod.cash.obs;
  final RxBool isLoading = false.obs;

  late String rideId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    amount.value = args['amount'] ?? 0.0;
    rideId = args['rideId'] ?? '';
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  Future<void> processPayment() async {
    if (selectedMethod.value == PaymentMethod.wallet && walletBalance.value < amount.value) {
      Fluttertoast.showToast(
        msg: 'Solde insuffisant',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (selectedMethod.value == PaymentMethod.mobileMoney) {
        await _processMobileMoneyPayment();
      } else if (selectedMethod.value == PaymentMethod.card) {
        await _processCardPayment();
      } else if (selectedMethod.value == PaymentMethod.wallet) {
        walletBalance.value -= amount.value;
      }

      Fluttertoast.showToast(
        msg: 'Paiement effectué avec succès',
        backgroundColor: Colors.green,
      );

      Get.back(result: true);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors du paiement',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processMobileMoneyPayment() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Mobile Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre numéro de téléphone'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '6XX XX XX XX',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCardPayment() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Carte bancaire'),
        content: const Text('Redirection vers la page de paiement sécurisée...'),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
