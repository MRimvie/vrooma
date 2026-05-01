import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/common/payment_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';
import '../../models/payment_model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with UIMixin {
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      appBar: AppBar(
        backgroundColor: contentTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: contentTheme.onBackground),
          onPressed: () => Get.back(),
        ),
        title: MyText.titleMedium(
          'Paiement',
          fontWeight: 700,
          fontSize: 20.sp,
          color: contentTheme.onBackground,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(),
            MySpacing.height(24),
            _buildPaymentMethods(),
            MySpacing.height(24),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: contentTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          MyText.bodySmall(
            'Montant à payer',
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
          MySpacing.height(8),
          Obx(() => MyText.headlineLarge(
                '${controller.amount.value.toStringAsFixed(0)} FCFA',
                fontWeight: 700,
                fontSize: 36.sp,
                color: Colors.white,
              )),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.titleMedium(
          'Méthode de paiement',
          fontWeight: 700,
          fontSize: 18.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(16),
        _buildPaymentMethod(
          'Espèces',
          'Payer en espèces au chauffeur',
          Icons.money,
          PaymentMethod.cash,
          Colors.green,
        ),
        MySpacing.height(12),
        _buildPaymentMethod(
          'Mobile Money',
          'Orange Money, Moov, Coris Money',
          Icons.phone_android,
          PaymentMethod.mobileMoney,
          Colors.orange,
        ),
        MySpacing.height(12),
        _buildPaymentMethod(
          'Carte bancaire',
          'Visa, Mastercard',
          Icons.credit_card,
          PaymentMethod.card,
          Colors.blue,
        ),
        MySpacing.height(12),
        _buildPaymentMethod(
          'Portefeuille',
          'Solde: ${controller.walletBalance.value.toStringAsFixed(0)} FCFA',
          Icons.account_balance_wallet,
          PaymentMethod.wallet,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(
    String title,
    String subtitle,
    IconData icon,
    PaymentMethod method,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.selectedMethod.value == method;
      return Container(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : contentTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : contentTheme.onBackground.withOpacity(0.1),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectPaymentMethod(method),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  MySpacing.width(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium(
                          title,
                          fontWeight: 600,
                          fontSize: 16.sp,
                          color: contentTheme.onBackground,
                        ),
                        MySpacing.height(4),
                        MyText.bodySmall(
                          subtitle,
                          fontSize: 12.sp,
                          color: contentTheme.onBackground.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).animate().fadeIn(delay: (method.index * 100).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildPayButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: contentTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.isLoading.value ? null : () => controller.processPayment(),
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: controller.isLoading.value
                    ? Center(
                        child: SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Center(
                        child: MyText.bodyLarge(
                          'Payer maintenant',
                          fontWeight: 700,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ));
  }
}
