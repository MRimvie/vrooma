import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../controller/client/home_map_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({Key? key}) : super(key: key);

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> with UIMixin {
  final HomeMapController controller = Get.put(HomeMapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildFullScreenMap()),
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
          Positioned(right: 16.w, bottom: 190.h, child: _buildCurrentLocationButton()),
          Positioned(left: 20.w, right: 20.w, bottom: 110.h, child: _buildMainActionButton()),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomSheetModal()),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildMapSelectionOverlay()),
          Positioned.fill(child: _buildSearchingDriverOverlay()),
        ],
      ),
    );
  }

  Widget _buildFullScreenMap() {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: controller.initialPosition,
        initialZoom: 14.0,
        onTap: (tapPosition, point) => controller.onMapTap(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.vrooma',
        ),
        MarkerLayer(markers: controller.markers.toList()),
        PolylineLayer(polylines: controller.polylines.toList()),
      ],
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.openDrawer(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.menu_rounded, color: contentTheme.primary, size: 22),
              ),
            ),
            MySpacing.width(12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        'Position actuelle',
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      MyText.bodyMedium(
                        controller.currentAddress.value,
                        fontWeight: 600,
                        fontSize: 13.sp,
                        color: Colors.grey.shade800,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
            ),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: contentTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.notifications_outlined, color: contentTheme.primary, size: 22),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: -0.2, end: 0),
    );
  }

  Widget _buildMainActionButton() {
    return Obx(() {
      if (!controller.isSelectingDestination.value) return const SizedBox.shrink();
      if (controller.bottomSheetHeight.value > 80) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => controller.selectDestination(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: contentTheme.primary.withOpacity(0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, color: Colors.white, size: 24),
              MySpacing.width(12),
              MyText.titleMedium(
                'Où allez-vous ?',
                fontWeight: 700,
                fontSize: 17.sp,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
    });
  }

  Widget _buildCurrentLocationButton() {
    return GestureDetector(
      onTap: () => controller.goToCurrentLocation(),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.my_location_rounded, color: contentTheme.primary, size: 24),
      ),
    );
  }

  Widget _buildBottomSheetModal() {
    return Obx(() {
      if (controller.bottomSheetHeight.value == 0) return const SizedBox.shrink();

      return GestureDetector(
        onVerticalDragUpdate: (details) {
          final newHeight = controller.bottomSheetHeight.value - details.delta.dy;
          if (newHeight >= 0 && newHeight <= 620) {
            controller.bottomSheetHeight.value = newHeight;
          }
          if (newHeight < 50) controller.bottomSheetHeight.value = 0;
        },
        child: Container(
          height: controller.bottomSheetHeight.value,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.r),
              topRight: Radius.circular(28.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: Obx(() => controller.isSelectingDestination.value
                    ? _buildDestinationSelection()
                    : _buildVehicleSelection()),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDestinationSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium(
            'Où allez-vous ?',
            fontWeight: 700,
            fontSize: 20.sp,
            color: Colors.grey.shade800,
          ),
          MySpacing.height(20),
          _buildLocationField(
            controller: controller.pickupController,
            label: 'Point de départ',
            icon: Icons.circle,
            iconColor: Colors.green,
            onTap: () => controller.selectPickupLocation(),
            mapMode: 'pickup',
          ),
          // Swap icon
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.swap_vert_rounded, color: contentTheme.primary, size: 20),
            ),
          ),
          _buildLocationField(
            controller: controller.destinationController,
            label: 'Destination',
            icon: Icons.location_on,
            iconColor: Colors.red,
            onTap: () => controller.selectDestinationFromSearch(),
            mapMode: 'destination',
          ),
          // Recent places
          Obx(() {
            if (controller.recentLocations.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(24),
                MyText.bodyMedium(
                  'Lieux enregistrés',
                  fontWeight: 700,
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
                MySpacing.height(12),
                ...controller.recentLocations.map((loc) => _buildRecentLocationItem(loc)),
              ],
            );
          }),
          MySpacing.height(24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.pickupLocation == null) {
                  Fluttertoast.showToast(
                    msg: 'Sélectionnez un point de départ',
                    backgroundColor: Colors.orange,
                  );
                  return;
                }
                if (controller.destinationLocation == null) {
                  Fluttertoast.showToast(
                    msg: 'Sélectionnez une destination',
                    backgroundColor: Colors.orange,
                  );
                  return;
                }
                controller.isSelectingDestination.value = false;
                controller.bottomSheetHeight.value = 500;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: contentTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: MyText.bodyLarge(
                'Confirmer les lieux',
                fontWeight: 700,
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLocationItem(Map<String, dynamic> loc) {
    return GestureDetector(
      onTap: () => controller.selectRecentLocation(loc),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.place_rounded, color: contentTheme.primary, size: 18),
            ),
            MySpacing.width(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    loc['name'],
                    fontWeight: 600,
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                  ),
                  MyText.bodySmall(
                    loc['address'],
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            Icon(Icons.north_west_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required String mapMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            MySpacing.width(14),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: true,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => this.controller.enableMapSelection(mapMode),
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.map_rounded, color: contentTheme.primary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary
          _buildRouteSummary(),
          MySpacing.height(20),
          MyText.titleMedium(
            'Choisissez votre véhicule',
            fontWeight: 700,
            fontSize: 18.sp,
            color: Colors.grey.shade800,
          ),
          MySpacing.height(14),
          Obx(() => Column(
                children: controller.vehicleTypes.map((vehicle) => _buildVehicleCard(vehicle)).toList(),
              )),
          MySpacing.height(16),
          // Promo code row
          _buildPromoCodeRow(),
          MySpacing.height(20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.confirmRide(),
              style: ElevatedButton.styleFrom(
                backgroundColor: contentTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  MySpacing.width(10),
                  MyText.bodyLarge(
                    'Confirmer la course',
                    fontWeight: 700,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Obx(() => Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: contentTheme.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  Container(
                    width: 1.5.w,
                    height: 20.h,
                    color: Colors.grey.shade300,
                  ),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ],
              ),
              MySpacing.width(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodySmall(
                      controller.pickupController.text.isNotEmpty
                          ? controller.pickupController.text
                          : 'Point de départ',
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MySpacing.height(14),
                    MyText.bodySmall(
                      controller.destinationController.text.isNotEmpty
                          ? controller.destinationController.text
                          : 'Destination',
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              MySpacing.width(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: MyText.bodySmall(
                      '${controller.distance.value.toStringAsFixed(1)} km',
                      fontWeight: 600,
                      fontSize: 11.sp,
                      color: contentTheme.primary,
                    ),
                  ),
                  MySpacing.height(6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: MyText.bodySmall(
                      '${controller.duration.value} min',
                      fontWeight: 600,
                      fontSize: 11.sp,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildPromoCodeRow() {
    return Obx(() => GestureDetector(
          onTap: () => controller.showPromoCodeDialog(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: controller.appliedPromoCode.value.isNotEmpty
                    ? Colors.green.withOpacity(0.4)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_rounded,
                  size: 20,
                  color: controller.appliedPromoCode.value.isNotEmpty
                      ? Colors.green
                      : contentTheme.primary,
                ),
                MySpacing.width(12),
                Expanded(
                  child: MyText.bodyMedium(
                    controller.appliedPromoCode.value.isNotEmpty
                        ? 'Code "${controller.appliedPromoCode.value}" appliqué'
                        : 'Ajouter un code promo',
                    fontWeight: 500,
                    fontSize: 14.sp,
                    color: controller.appliedPromoCode.value.isNotEmpty
                        ? Colors.green
                        : Colors.grey.shade600,
                  ),
                ),
                Icon(
                  controller.appliedPromoCode.value.isNotEmpty
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  size: 20,
                  color: controller.appliedPromoCode.value.isNotEmpty
                      ? Colors.green
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final isSelected = controller.selectedVehicleType.value == vehicle['type'];
    return GestureDetector(
      onTap: () => controller.selectedVehicleType.value = vehicle['type'],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? contentTheme.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? contentTheme.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? contentTheme.primary.withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                vehicle['icon'] as IconData,
                size: 28,
                color: isSelected ? contentTheme.primary : Colors.grey.shade600,
              ),
            ),
            MySpacing.width(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyText.bodyMedium(
                        vehicle['name'],
                        fontWeight: 700,
                        fontSize: 15.sp,
                        color: isSelected ? contentTheme.primary : Colors.grey.shade800,
                      ),
                      MySpacing.width(8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_rounded, size: 10, color: Colors.grey.shade500),
                            MySpacing.width(2),
                            MyText.bodySmall(
                              '${vehicle['capacity']}',
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  MyText.bodySmall(
                    vehicle['description'],
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText.titleMedium(
                  vehicle['price'] > 0
                      ? '${vehicle['price']} F'
                      : '---',
                  fontWeight: 700,
                  fontSize: 15.sp,
                  color: isSelected ? contentTheme.primary : Colors.grey.shade800,
                ),
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: contentTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSelectionOverlay() {
    return Obx(() {
      if (!controller.isSelectingOnMap.value) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: contentTheme.primary,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: contentTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
            MySpacing.width(12),
            Expanded(
              child: MyText.bodyMedium(
                controller.selectionMode.value == 'pickup'
                    ? 'Touchez la carte pour le départ'
                    : 'Touchez la carte pour la destination',
                fontWeight: 600,
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.isSelectingOnMap.value = false;
                controller.bottomSheetHeight.value = 400;
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0).fadeIn();
    });
  }

  Widget _buildSearchingDriverOverlay() {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(32.w),
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
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
                  child: Icon(Icons.local_taxi_rounded, size: 48, color: contentTheme.primary),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
                MySpacing.height(24),
                MyText.titleMedium(
                  'Recherche de chauffeur...',
                  fontWeight: 700,
                  fontSize: 20.sp,
                  color: Colors.grey.shade800,
                  textAlign: TextAlign.center,
                ),
                MySpacing.height(10),
                MyText.bodyMedium(
                  'Nous recherchons le meilleur chauffeur\npour vous',
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
                MySpacing.height(24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(contentTheme.primary),
                    minHeight: 4.h,
                  ),
                ),
              ],
            ),
          ).animate().scale().fadeIn(),
        ),
      );
    });
  }
}
