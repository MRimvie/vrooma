import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/auth/otp_controller.dart';
import '../../helpers/my_widgets/my_button.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({Key? key}) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> with UIMixin {
  final OTPController controller = Get.put(OTPController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(20),
              _buildHeader(),
              MySpacing.height(50),
              _buildOTPInput(),
              MySpacing.height(30),
              _buildVerifyButton(),
              MySpacing.height(20),
              _buildResendSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: contentTheme.onBackground,
          ),
        ),
        MySpacing.height(30),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.message_outlined,
            size: 40,
            color: contentTheme.primary,
          ),
        ),
        MySpacing.height(24),
        MyText.titleLarge(
          'Vérification',
          fontWeight: 700,
          fontSize: 32.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(8),
        MyText.bodyMedium(
          'Entrez le code envoyé au ${controller.phoneNumber}',
          fontSize: 16.sp,
          color: contentTheme.onBackground.withOpacity(0.6),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildOTPInput() {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: controller.otpController,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12.r),
            fieldHeight: 56.h,
            fieldWidth: 48.w,
            activeFillColor: contentTheme.background,
            inactiveFillColor: contentTheme.background,
            selectedFillColor: contentTheme.background,
            activeColor: contentTheme.primary,
            inactiveColor: contentTheme.onBackground.withOpacity(0.1),
            selectedColor: contentTheme.primary,
            borderWidth: 2,
          ),
          cursorColor: contentTheme.primary,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          textStyle: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: contentTheme.onBackground,
          ),
          onChanged: (value) => controller.validateOTP(),
          onCompleted: (value) => controller.verifyOTP(),
        ),
        Obx(() {
          if (controller.otpError.value.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red),
                  MySpacing.width(8),
                  MyText.bodySmall(
                    controller.otpError.value,
                    color: Colors.red,
                    fontSize: 12.sp,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildVerifyButton() {
    return Obx(() => MyButton.large(
          onPressed: controller.isLoading.value ? null : () => controller.verifyOTP(),
          elevation: 0,
          borderRadiusAll: 12,
          padding: MySpacing.xy(20, 18),
          block: true,
          backgroundColor: contentTheme.primary,
          child: controller.isLoading.value
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(contentTheme.onPrimary),
                  ),
                )
              : MyText.bodyMedium(
                  'Vérifier',
                  fontWeight: 600,
                  fontSize: 16.sp,
                  color: contentTheme.onPrimary,
                ),
        )).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildResendSection() {
    return Obx(() => Center(
          child: Column(
            children: [
              if (controller.canResend.value)
                TextButton(
                  onPressed: () => controller.resendOTP(),
                  child: MyText.bodyMedium(
                    'Renvoyer le code',
                    fontWeight: 600,
                    fontSize: 14.sp,
                    color: contentTheme.primary,
                  ),
                )
              else
                MyText.bodyMedium(
                  'Renvoyer le code dans ${controller.resendTimer.value}s',
                  fontSize: 14.sp,
                  color: contentTheme.onBackground.withOpacity(0.5),
                ),
            ],
          ),
        )).animate().fadeIn(delay: 600.ms);
  }
}
