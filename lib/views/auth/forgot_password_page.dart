import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/auth/forgot_password_controller.dart';
import '../../helpers/my_widgets/my_button.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with UIMixin {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(40),
              _buildBackButton(),
              MySpacing.height(40),
              _buildHeader(),
              MySpacing.height(50),
              _buildPhoneField(),
              MySpacing.height(32),
              _buildSendButton(),
              MySpacing.height(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: contentTheme.onBackground.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: contentTheme.onBackground,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40,
            color: contentTheme.primary,
          ),
        ).animate().scale(duration: 600.ms).shimmer(delay: 300.ms),
        MySpacing.height(24),
        MyText.titleLarge(
          'Mot de passe oublié ?',
          fontWeight: 800,
          fontSize: 32.sp,
          color: contentTheme.onBackground,
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        MySpacing.height(12),
        MyText.bodyLarge(
          'Entrez votre numéro de téléphone pour recevoir un code de réinitialisation',
          fontSize: 16.sp,
          color: contentTheme.onBackground.withOpacity(0.6),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Numéro de téléphone',
          fontWeight: 600,
          fontSize: 14.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(8),
        Container(
          decoration: BoxDecoration(
            color: contentTheme.onBackground.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: contentTheme.onBackground.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: 16.sp,
              color: contentTheme.onBackground,
            ),
            decoration: InputDecoration(
              hintText: '70 12 34 56',
              hintStyle: TextStyle(
                color: contentTheme.onBackground.withOpacity(0.4),
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: contentTheme.primary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildSendButton() {
    return Obx(() => MyButton.large(
          onPressed: controller.isLoading.value ? null : controller.sendResetCode,
          elevation: 0,
          borderRadiusAll: 16,
          padding: MySpacing.y(18),
          block: true,
          backgroundColor: contentTheme.primary,
          child: controller.isLoading.value
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : MyText.bodyLarge(
                  'Envoyer le code',
                  fontWeight: 700,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
        )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0);
  }
}
