import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          _buildMap(),
          _buildBottomSheet(),
          _buildMapSelectionOverlay(),
          _buildTopBar(),
          _buildCurrentLocationButton(),
          _buildMainActionButton(),
          _buildSearchingDriverOverlay(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() => FlutterMap(
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
            MarkerLayer(
              markers: controller.markers.toList(),
            ),
            PolylineLayer(
              polylines: controller.polylines.toList(),
            ),
          ],
        ));
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
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
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.menu,
                  color: contentTheme.primary,
                  size: 24,
                ),
              ),
            ),
            MySpacing.width(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(
                    'Votre position',
                    fontSize: 12.sp,
                    color: contentTheme.onBackground.withOpacity(0.6),
                  ),
                  Obx(() => MyText.bodyMedium(
                        controller.currentAddress.value,
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: contentTheme.onBackground,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/notifications'),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: contentTheme.primary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0),
    );
  }

  Widget _buildBottomSheet() {
    return Obx(() => AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) => controller.onDragUpdate(details),
            child: Container(
              height: controller.bottomSheetHeight.value,
              decoration: BoxDecoration(
                color: controller.bottomSheetHeight.value < 100 
                    ? Colors.transparent 
                    : contentTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: controller.bottomSheetHeight.value < 100 
                    ? [] 
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
              ),
            child: Column(
              children: [
                _buildDragHandle(),
                if (controller.bottomSheetHeight.value >= 100)
                  Expanded(
                    child: controller.bottomSheetHeight.value < 200
                        ? _buildWelcomeMessage()
                        : (controller.isSelectingDestination.value
                            ? _buildDestinationSelection()
                            : _buildVehicleSelection()),
                  ),
              ],
            ),
          ),
        )));
  }

  Widget _buildDragHandle() {
    return Obx(() => controller.bottomSheetHeight.value < 100
        ? const SizedBox.shrink()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: contentTheme.onBackground.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ));
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: contentTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.waving_hand,
              color: contentTheme.primary,
              size: 20,
            ),
          ),
          MySpacing.width(12),
          Expanded(
            child: MyText.bodyMedium(
              'Bienvenue ! Où allez-vous ?',
              fontWeight: 600,
              fontSize: 14.sp,
              color: contentTheme.onBackground,
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildDestinationSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium(
            'Où allez-vous ?',
            fontWeight: 700,
            fontSize: 24.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(20),
          _buildLocationInput(
            icon: Icons.my_location,
            iconColor: contentTheme.primary,
            label: 'Point de départ',
            controller: controller.pickupController,
            onTap: () => controller.selectPickupLocation(),
          ),
          MySpacing.height(12),
          _buildLocationInput(
            icon: Icons.location_on,
            iconColor: Colors.red,
            label: 'Destination',
            controller: controller.destinationController,
            onTap: () => controller.selectDestination(),
          ),
          MySpacing.height(24),
          _buildRecentLocations(),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                MySpacing.width(12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: contentTheme.onBackground,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: TextStyle(
                        color: contentTheme.onBackground.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => this.controller.enableMapSelection(
                    label.contains('départ') ? 'pickup' : 'destination',
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.map,
                      color: contentTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Lieux récents',
          fontWeight: 600,
          fontSize: 14.sp,
          color: contentTheme.onBackground.withOpacity(0.6),
        ),
        MySpacing.height(12),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentLocations.length,
              separatorBuilder: (_, __) => MySpacing.height(8),
              itemBuilder: (context, index) {
                final location = controller.recentLocations[index];
                return _buildLocationItem(
                  icon: Icons.history,
                  title: location['name'],
                  subtitle: location['address'],
                  onTap: () => controller.selectRecentLocation(location),
                );
              },
            )),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: contentTheme.onBackground.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: contentTheme.onBackground.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: contentTheme.onBackground.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium(
                        title,
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.height(2),
                      MyText.bodySmall(
                        subtitle,
                        fontSize: 12.sp,
                        color: contentTheme.onBackground.withOpacity(0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium(
            'Choisir un véhicule',
            fontWeight: 700,
            fontSize: 24.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(8),
          Obx(() => MyText.bodySmall(
                '${controller.distance.value.toStringAsFixed(1)} km • ${controller.duration.value} min',
                fontSize: 12.sp,
                color: contentTheme.onBackground.withOpacity(0.6),
              )),
          MySpacing.height(20),
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.vehicleTypes.length,
                separatorBuilder: (_, __) => MySpacing.height(12),
                itemBuilder: (context, index) {
                  final vehicle = controller.vehicleTypes[index];
                  final isSelected = controller.selectedVehicleType.value == vehicle['type'];
                  return _buildVehicleCard(vehicle, isSelected);
                },
              )),
          MySpacing.height(20),
          _buildPromoCodeSection(),
          MySpacing.height(20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? contentTheme.primary.withOpacity(0.1)
            : contentTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? contentTheme.primary
              : contentTheme.onBackground.withOpacity(0.1),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectVehicleType(vehicle['type']),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? contentTheme.primary.withOpacity(0.2)
                        : contentTheme.onBackground.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    vehicle['icon'],
                    color: isSelected
                        ? contentTheme.primary
                        : contentTheme.onBackground,
                    size: 28,
                  ),
                ),
                MySpacing.width(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MyText.bodyMedium(
                            vehicle['name'],
                            fontWeight: 600,
                            fontSize: 16.sp,
                            color: contentTheme.onBackground,
                          ),
                          MySpacing.width(8),
                          Icon(
                            Icons.person,
                            size: 14,
                            color: contentTheme.onBackground.withOpacity(0.5),
                          ),
                          MySpacing.width(4),
                          MyText.bodySmall(
                            '${vehicle['capacity']}',
                            fontSize: 12.sp,
                            color: contentTheme.onBackground.withOpacity(0.5),
                          ),
                        ],
                      ),
                      MySpacing.height(4),
                      MyText.bodySmall(
                        vehicle['description'],
                        fontSize: 12.sp,
                        color: contentTheme.onBackground.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                MySpacing.width(12),
                MyText.bodyLarge(
                  '${vehicle['price']} FCFA',
                  fontWeight: 700,
                  fontSize: 16.sp,
                  color: isSelected
                      ? contentTheme.primary
                      : contentTheme.onBackground,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * vehicle['type']).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildPromoCodeSection() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: contentTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: contentTheme.primary.withOpacity(0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.showPromoCodeDialog(),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      color: contentTheme.primary,
                      size: 20,
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: MyText.bodyMedium(
                        controller.appliedPromoCode.value.isEmpty
                            ? 'Ajouter un code promo'
                            : 'Code: ${controller.appliedPromoCode.value}',
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: contentTheme.primary,
                      ),
                    ),
                    if (controller.appliedPromoCode.value.isNotEmpty)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildConfirmButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              onTap: controller.isLoading.value ? null : () => controller.confirmRide(),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              contentTheme.onPrimary,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText.bodyLarge(
                            'Confirmer la course',
                            fontWeight: 700,
                            fontSize: 16.sp,
                            color: contentTheme.onPrimary,
                          ),
                          MySpacing.width(8),
                          Icon(
                            Icons.arrow_forward,
                            color: contentTheme.onPrimary,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ));
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      right: 16.w,
      bottom: controller.bottomSheetHeight.value + 20.h,
      child: Container(
        decoration: BoxDecoration(
          color: contentTheme.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.goToCurrentLocation(),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Icon(
                Icons.my_location,
                color: contentTheme.primary,
                size: 24,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.5, 0.5)),
    );
  }

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
                        'Touchez la carte',
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
                        onTap: () {
                          controller.isSelectingOnMap.value = false;
                          controller.bottomSheetHeight.value = 300;
                        },
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
                ).animate().scale(duration: 1000.ms).then().scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.2, 1.2),
                      duration: 500.ms,
                    ).then().scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                    ),
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
                  ).animate(onPlay: (controller) => controller.repeat())
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
                      backgroundColor: contentTheme.onBackground.withOpacity(0.1),
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

  Widget _buildMainActionButton() {
    return Obx(() {
      if (!controller.isSelectingDestination.value) return const SizedBox.shrink();
      
      return Positioned(
        left: 16.w,
        right: 16.w,
        bottom: 120.h,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: contentTheme.primary.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.bottomSheetHeight.value = 300;
                controller.selectDestination();
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_taxi,
                      color: Colors.white,
                      size: 28,
                    ),
                    MySpacing.width(12),
                    MyText.titleMedium(
                      'Où allez-vous ?',
                      fontWeight: 700,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0).shimmer(delay: 1000.ms, duration: 2000.ms),
      );
    });
  }
}
