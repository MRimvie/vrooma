import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/auth/login_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with UIMixin {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(56),
              _buildHeader(),
              MySpacing.height(44),
              _buildLoginForm(),
              MySpacing.height(20),
              _buildRememberAndForgot(),
              MySpacing.height(28),
              _buildLoginButton(),
              MySpacing.height(20),
              _buildDevHint(),
              MySpacing.height(24),
              _buildDivider(),
              MySpacing.height(24),
              _buildRegisterSection(),
              MySpacing.height(40),
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
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(Icons.local_taxi_rounded, size: 40, color: contentTheme.primary),
        ).animate().scale(duration: 600.ms).shimmer(delay: 300.ms),
        MySpacing.height(24),
        MyText.titleLarge(
          'Bon retour !',
          fontWeight: 800,
          fontSize: 32.sp,
          color: contentTheme.onBackground,
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        MySpacing.height(6),
        MyText.bodyLarge(
          'Connectez-vous pour continuer',
          fontSize: 15.sp,
          color: contentTheme.onBackground.withOpacity(0.55),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Champ téléphone avec prefix +226
        Obx(() => _buildPhoneField())
            .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        MySpacing.height(20),
        // Champ mot de passe
        Obx(() => _buildPasswordField())
            .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildPhoneField() {
    final hasError = controller.phoneError.value.isNotEmpty;
    final isFocused = controller.isPhoneFocused.value;

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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError
                ? Colors.red.withOpacity(0.04)
                : isFocused
                    ? contentTheme.primary.withOpacity(0.04)
                    : contentTheme.onBackground.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : isFocused
                      ? contentTheme.primary
                      : contentTheme.onBackground.withOpacity(0.12),
              width: hasError || isFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Préfixe Burkina Faso
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: contentTheme.onBackground.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText.bodyMedium('🇧🇫', fontSize: 20.sp),
                    MySpacing.width(6),
                    MyText.bodyMedium(
                      '+226',
                      fontWeight: 600,
                      fontSize: 15.sp,
                      color: contentTheme.onBackground,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  focusNode: controller.phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 15.sp, color: contentTheme.onBackground),
                  decoration: InputDecoration(
                    hintText: '70 12 34 56',
                    hintStyle: TextStyle(
                      color: contentTheme.onBackground.withOpacity(0.35),
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                ),
              ),
              if (!hasError && controller.phoneController.text.length >= 8)
                Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: Icon(Icons.check_circle_rounded,
                      size: 20, color: Colors.green),
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 14, color: Colors.red),
                MySpacing.width(5),
                MyText.bodySmall(
                  controller.phoneError.value,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final hasError = controller.passwordError.value.isNotEmpty &&
        controller.passwordError.value.trim().isNotEmpty;
    final isFocused = controller.isPasswordFocused.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Mot de passe',
          fontWeight: 600,
          fontSize: 14.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError
                ? Colors.red.withOpacity(0.04)
                : isFocused
                    ? contentTheme.primary.withOpacity(0.04)
                    : contentTheme.onBackground.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : isFocused
                      ? contentTheme.primary
                      : contentTheme.onBackground.withOpacity(0.12),
              width: hasError || isFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: hasError
                      ? Colors.red
                      : isFocused
                          ? contentTheme.primary
                          : contentTheme.onBackground.withOpacity(0.4),
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  obscureText: controller.obscurePassword.value,
                  style: TextStyle(fontSize: 15.sp, color: contentTheme.onBackground),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      color: contentTheme.onBackground.withOpacity(0.35),
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: contentTheme.onBackground.withOpacity(0.4),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 14, color: Colors.red),
                MySpacing.width(5),
                MyText.bodySmall(
                  controller.passwordError.value.trim(),
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => GestureDetector(
              onTap: controller.toggleRememberMe,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: controller.rememberMe.value
                          ? contentTheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: controller.rememberMe.value
                            ? contentTheme.primary
                            : contentTheme.onBackground.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: controller.rememberMe.value
                        ? Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                  MySpacing.width(10),
                  MyText.bodyMedium(
                    'Rester connecté',
                    fontSize: 14.sp,
                    color: contentTheme.onBackground.withOpacity(0.8),
                  ),
                ],
              ),
            )).animate().fadeIn(delay: 500.ms),
        GestureDetector(
          onTap: () => Get.toNamed('/auth/forgot-password'),
          child: MyText.bodyMedium(
            'Mot de passe oublié ?',
            fontSize: 14.sp,
            fontWeight: 600,
            color: contentTheme.primary,
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: contentTheme.primary,
              disabledBackgroundColor: contentTheme.primary.withOpacity(0.6),
              padding: EdgeInsets.symmetric(vertical: 17.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : MyText.bodyLarge(
                    'Se connecter',
                    fontWeight: 700,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
          ),
        )).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDevHint() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade600),
          MySpacing.width(10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade700),
                children: const [
                  TextSpan(text: 'Test client : '),
                  TextSpan(
                    text: '70123456',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '  •  Chauffeur : '),
                  TextSpan(
                    text: '75987654',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '  •  MDP : '),
                  TextSpan(
                    text: '123456',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 650.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: contentTheme.onBackground.withOpacity(0.15), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: MyText.bodySmall(
            'OU',
            fontSize: 11.sp,
            fontWeight: 600,
            color: contentTheme.onBackground.withOpacity(0.4),
          ),
        ),
        Expanded(
          child: Divider(color: contentTheme.onBackground.withOpacity(0.15), thickness: 1),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildRegisterSection() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.toNamed('/auth/register'),
        child: RichText(
          text: TextSpan(
            text: 'Pas encore de compte ? ',
            style: TextStyle(
              fontSize: 14.sp,
              color: contentTheme.onBackground.withOpacity(0.6),
            ),
            children: [
              TextSpan(
                text: 'S\'inscrire gratuitement',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: contentTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
