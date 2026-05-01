import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/auth/phone_auth_controller.dart';
import '../../helpers/my_widgets/my_button.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';
import '../../widgets/custom_textfield.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({Key? key}) : super(key: key);

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> with UIMixin {
  final PhoneAuthController controller = Get.put(PhoneAuthController());

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
              _buildPhoneInput(),
              MySpacing.height(30),
              _buildContinueButton(),
              MySpacing.height(20),
              _buildDivider(),
              MySpacing.height(20),
              _buildEmailOption(),
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
        MyText.titleLarge(
          'Bienvenue',
          fontWeight: 700,
          fontSize: 32.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(8),
        MyText.bodyMedium(
          'Entrez votre numéro de téléphone pour continuer',
          fontSize: 16.sp,
          color: contentTheme.onBackground.withOpacity(0.6),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPhoneInput() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.bodySmall(
              'Numéro de téléphone',
              fontWeight: 600,
              fontSize: 14.sp,
              color: contentTheme.onBackground,
            ),
            MySpacing.height(8),
            Container(
              decoration: BoxDecoration(
                color: contentTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: controller.phoneError.value.isEmpty
                      ? contentTheme.onBackground.withOpacity(0.1)
                      : Colors.red,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: contentTheme.onBackground.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        MyText.bodyMedium(
                          '��',
                          fontSize: 24.sp,
                        ),
                        MySpacing.width(8),
                        MyText.bodyMedium(
                          '+226',
                          fontWeight: 600,
                          fontSize: 16.sp,
                          color: contentTheme.onBackground,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: contentTheme.onBackground.withOpacity(0.1),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: contentTheme.onBackground,
                      ),
                      decoration: InputDecoration(
                        hintText: '70 XX XX XX',
                        hintStyle: TextStyle(
                          color: contentTheme.onBackground.withOpacity(0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      onChanged: (value) => controller.validatePhone(),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.phoneError.value.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 4.w),
                child: MyText.bodySmall(
                  controller.phoneError.value,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
          ],
        )).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildContinueButton() {
    return Obx(() => MyButton.large(
          onPressed: controller.isLoading.value ? null : () => controller.sendOTP(),
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
                  'Continuer',
                  fontWeight: 600,
                  fontSize: 16.sp,
                  color: contentTheme.onPrimary,
                ),
        )).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: contentTheme.onBackground.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: MyText.bodySmall(
            'OU',
            color: contentTheme.onBackground.withOpacity(0.4),
            fontSize: 12.sp,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: contentTheme.onBackground.withOpacity(0.1),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildEmailOption() {
    return Container(
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: contentTheme.onBackground.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/auth/email'),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: contentTheme.onBackground,
                ),
                MySpacing.width(12),
                MyText.bodyMedium(
                  'Continuer avec Email',
                  fontWeight: 600,
                  fontSize: 16.sp,
                  color: contentTheme.onBackground,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
