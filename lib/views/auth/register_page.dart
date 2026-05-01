import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/auth/register_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with UIMixin {
  final RegisterController controller = Get.put(RegisterController());

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
              MySpacing.height(40),
              _buildBackButton(),
              MySpacing.height(24),
              _buildHeader(),
              MySpacing.height(36),
              Obx(() => _buildNameField())
                  .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(20),
              Obx(() => _buildPhoneField())
                  .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(20),
              Obx(() => _buildPasswordField())
                  .animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(20),
              Obx(() => _buildConfirmPasswordField())
                  .animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(28),
              _buildRoleSelection()
                  .animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(24),
              Obx(() => _buildTermsCheckbox())
                  .animate().fadeIn(delay: 750.ms),
              MySpacing.height(28),
              Obx(() => _buildRegisterButton())
                  .animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              MySpacing.height(20),
              _buildLoginSection()
                  .animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
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
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Icons.person_add_rounded, size: 36, color: contentTheme.primary),
        ).animate().scale(duration: 600.ms).shimmer(delay: 300.ms),
        MySpacing.height(20),
        MyText.titleLarge(
          'Créer un compte',
          fontWeight: 800,
          fontSize: 32.sp,
          color: contentTheme.onBackground,
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        MySpacing.height(6),
        MyText.bodyLarge(
          'Rejoignez-nous en quelques secondes',
          fontSize: 15.sp,
          color: contentTheme.onBackground.withOpacity(0.55),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildNameField() {
    final hasError = controller.nameError.value.isNotEmpty;
    final isFocused = controller.isNameFocused.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Nom complet',
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
                  Icons.person_outline_rounded,
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
                  controller: controller.nameController,
                  focusNode: controller.nameFocus,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 15.sp, color: contentTheme.onBackground),
                  decoration: InputDecoration(
                    hintText: 'Jean Ouédraogo',
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
              if (!hasError && controller.nameError.value.isEmpty &&
                  controller.nameController.text.length >= 3)
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
                  controller.nameError.value,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
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
                  focusNode: controller.phoneFocus,
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
              if (!hasError &&
                  controller.phoneController.text
                          .replaceAll(RegExp(r'\D'), '')
                          .length >=
                      8)
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
    final hasError = controller.passwordError.value.isNotEmpty;
    final isFocused = controller.isPasswordFocused.value;
    final strength = controller.passwordStrength.value;

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
                  focusNode: controller.passwordFocus,
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
                  controller.passwordError.value,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
        if (strength > 0) ...[
          MySpacing.height(10),
          _buildPasswordStrengthBar(strength),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthBar(int strength) {
    const labels = ['', 'Faible', 'Moyen', 'Bon', 'Fort'];
    const colors = [
      Colors.transparent,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
    ];
    final color = colors[strength];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4.h,
                margin: EdgeInsets.only(right: index < 3 ? 4.w : 0),
                decoration: BoxDecoration(
                  color: index < strength
                      ? color
                      : contentTheme.onBackground.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }),
        ),
        MySpacing.height(6),
        Row(
          children: [
            MyText.bodySmall(
              'Sécurité : ',
              fontSize: 11.sp,
              color: contentTheme.onBackground.withOpacity(0.5),
            ),
            MyText.bodySmall(
              labels[strength],
              fontSize: 11.sp,
              fontWeight: 600,
              color: color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    final hasError = controller.confirmError.value.isNotEmpty;
    final isFocused = controller.isConfirmFocused.value;
    final matches = controller.passwordsMatch.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Confirmer le mot de passe',
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
                : matches
                    ? Colors.green.withOpacity(0.04)
                    : isFocused
                        ? contentTheme.primary.withOpacity(0.04)
                        : contentTheme.onBackground.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : matches
                      ? Colors.green
                      : isFocused
                          ? contentTheme.primary
                          : contentTheme.onBackground.withOpacity(0.12),
              width: hasError || isFocused || matches ? 1.5 : 1,
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
                      : matches
                          ? Colors.green
                          : isFocused
                              ? contentTheme.primary
                              : contentTheme.onBackground.withOpacity(0.4),
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.confirmPasswordController,
                  focusNode: controller.confirmFocus,
                  obscureText: controller.obscureConfirmPassword.value,
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
                onPressed: controller.toggleConfirmPasswordVisibility,
                icon: Icon(
                  controller.obscureConfirmPassword.value
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
                  controller.confirmError.value,
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ],
            ),
          )
        else if (matches)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                MySpacing.width(5),
                MyText.bodySmall(
                  'Mots de passe identiques',
                  color: Colors.green,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Je m\'inscris en tant que',
          fontWeight: 600,
          fontSize: 14.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(12),
        Obx(() => Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    'Client',
                    Icons.person_outline_rounded,
                    'Réserver des courses',
                    controller.selectedRole.value == 'client',
                    () => controller.selectRole('client'),
                  ),
                ),
                MySpacing.width(14),
                Expanded(
                  child: _buildRoleCard(
                    'Chauffeur',
                    Icons.local_taxi_rounded,
                    'Offrir mes services',
                    controller.selectedRole.value == 'driver',
                    () => controller.selectRole('driver'),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildRoleCard(
    String title,
    IconData icon,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? contentTheme.primary.withOpacity(0.08)
              : contentTheme.onBackground.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? contentTheme.primary
                : contentTheme.onBackground.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? contentTheme.primary.withOpacity(0.15)
                    : contentTheme.onBackground.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? contentTheme.primary
                    : contentTheme.onBackground.withOpacity(0.45),
              ),
            ),
            MySpacing.height(10),
            MyText.bodyMedium(
              title,
              fontWeight: 700,
              fontSize: 14.sp,
              color: isSelected ? contentTheme.primary : contentTheme.onBackground,
            ),
            MySpacing.height(4),
            MyText.bodySmall(
              subtitle,
              fontSize: 11.sp,
              textAlign: TextAlign.center,
              color: isSelected
                  ? contentTheme.primary.withOpacity(0.7)
                  : contentTheme.onBackground.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: controller.toggleTerms,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: controller.acceptedTerms.value
                  ? contentTheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: controller.acceptedTerms.value
                    ? contentTheme.primary
                    : contentTheme.onBackground.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: controller.acceptedTerms.value
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          MySpacing.width(12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'J\'accepte les ',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: contentTheme.onBackground.withOpacity(0.7),
                ),
                children: [
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' et la ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: contentTheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.register,
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
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : MyText.bodyLarge(
                'S\'inscrire',
                fontWeight: 700,
                fontSize: 16.sp,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
        child: RichText(
          text: TextSpan(
            text: 'Vous avez déjà un compte ? ',
            style: TextStyle(
              fontSize: 14.sp,
              color: contentTheme.onBackground.withOpacity(0.6),
            ),
            children: [
              TextSpan(
                text: 'Se connecter',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: contentTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
