import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/client/home_map_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

mixin HomeMapPageOverlayMixin on State {
  HomeMapController get controller;
  dynamic get contentTheme;

  Widget _buildMapSelectionOverlay() {
    return Obx(() {
      if (!controller.isSelectingOnMap.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  margin: EdgeInsets.symmetric(horizontal: 32.w),
                  decoration: BoxDecoration(
                    color: contentTheme.background,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 48,
                        color: contentTheme.primary,
                      ),
                      MySpacing.height(16),
                      MyText.titleMedium(
                        controller.selectionMode.value == 'pickup'
                            ? 'Touchez la carte'
                            : 'Touchez la carte',
                        fontWeight: 700,
                        fontSize: 20.sp,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.height(8),
                      MyText.bodyMedium(
                        controller.selectionMode.value == 'pickup'
                            ? 'pour sélectionner votre point de départ'
                            : 'pour sélectionner votre destination',
                        fontSize: 14.sp,
                        color: contentTheme.onBackground.withOpacity(0.7),
                        textAlign: TextAlign.center,
                      ),
                      MySpacing.height(20),
                      GestureDetector(
                        onTap: () => controller.isSelectingOnMap.value = false,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: contentTheme.onBackground.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: MyText.bodyMedium(
                            'Annuler',
                            fontWeight: 600,
                            fontSize: 14.sp,
                            color: contentTheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale().fadeIn(),
                MySpacing.height(100),
                Icon(
                  Icons.location_on,
                  size: 60,
                  color: contentTheme.primary,
                )
                    .animate()
                    .scale(
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.2, 1.2),
                      duration: 500.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                    )
                    .loop(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSearchingDriverOverlay() {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(32.w),
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              decoration: BoxDecoration(
                color: contentTheme.background,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_taxi,
                      size: 48,
                      color: contentTheme.primary,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 2000.ms),
                  MySpacing.height(24),
                  MyText.titleLarge(
                    'Recherche de chauffeur...',
                    fontWeight: 700,
                    fontSize: 22.sp,
                    color: contentTheme.onBackground,
                    textAlign: TextAlign.center,
                  ),
                  MySpacing.height(12),
                  MyText.bodyMedium(
                    'Nous recherchons le meilleur chauffeur\npour vous',
                    fontSize: 14.sp,
                    color: contentTheme.onBackground.withOpacity(0.6),
                    textAlign: TextAlign.center,
                  ),
                  MySpacing.height(24),
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      backgroundColor:
                          contentTheme.onBackground.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        contentTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale().fadeIn(),
          ),
        ),
      );
    });
  }
}
