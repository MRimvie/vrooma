import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/driver/driver_home_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> with UIMixin {
  final DriverHomeController controller = Get.put(DriverHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildStatusToggle(),
          _buildLocationFab(),
          _buildStatsCard(),
          _buildRideRequestDialog(),
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
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.vrooma',
            ),
            MarkerLayer(markers: controller.markers.toList()),
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
                child: Icon(Icons.menu_rounded, color: contentTheme.primary, size: 22),
              ),
            ),
            MySpacing.width(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(
                    'Bonjour,',
                    fontSize: 11.sp,
                    color: contentTheme.onBackground.withOpacity(0.5),
                  ),
                  Obx(() => MyText.bodyMedium(
                        controller.driverName.value,
                        fontWeight: 700,
                        fontSize: 15.sp,
                        color: contentTheme.onBackground,
                      )),
                ],
              ),
            ),
            // Rating badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                  MySpacing.width(4),
                  MyText.bodySmall(
                    '4.9',
                    fontWeight: 700,
                    fontSize: 13.sp,
                    color: Colors.amber.shade800,
                  ),
                ],
              ),
            ),
            MySpacing.width(8),
            GestureDetector(
              onTap: () => Get.toNamed('/notifications'),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.notifications_outlined, color: contentTheme.primary, size: 22),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0),
    );
  }

  Widget _buildStatusToggle() {
    return Positioned(
      top: 110.h,
      left: 16.w,
      right: 16.w,
      child: Obx(() => Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: contentTheme.background,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    'En ligne',
                    Icons.check_circle_rounded,
                    const Color(0xFF22C55E),
                    controller.isOnline.value,
                    () => controller.toggleOnlineStatus(true),
                  ),
                ),
                MySpacing.width(8),
                Expanded(
                  child: _buildStatusButton(
                    'Hors ligne',
                    Icons.cancel_rounded,
                    Colors.red,
                    !controller.isOnline.value,
                    () => controller.toggleOnlineStatus(false),
                  ),
                ),
              ],
            ),
          )).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),
    );
  }

  Widget _buildStatusButton(
    String label,
    IconData icon,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isActive ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? color : contentTheme.onBackground.withOpacity(0.35),
                  size: 20,
                ),
                MySpacing.width(8),
                MyText.bodyMedium(
                  label,
                  fontWeight: 600,
                  fontSize: 14.sp,
                  color: isActive ? color : contentTheme.onBackground.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFab() {
    return Positioned(
      right: 16.w,
      bottom: 220.h,
      child: GestureDetector(
        onTap: () {
          controller.mapController?.move(controller.initialPosition, 14.0);
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: contentTheme.background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.my_location_rounded, color: contentTheme.primary, size: 24),
        ),
      ).animate().fadeIn(delay: 400.ms).scale(),
    );
  }

  Widget _buildStatsCard() {
    return Positioned(
      bottom: 20.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  'Aujourd\'hui',
                  fontWeight: 700,
                  fontSize: 18.sp,
                  color: contentTheme.onBackground,
                ),
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: controller.isOnline.value
                            ? const Color(0xFF22C55E).withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: controller.isOnline.value
                                  ? const Color(0xFF22C55E)
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          MySpacing.width(6),
                          MyText.bodySmall(
                            controller.isOnline.value ? 'En ligne' : 'Hors ligne',
                            fontWeight: 600,
                            fontSize: 12.sp,
                            color: controller.isOnline.value
                                ? const Color(0xFF22C55E)
                                : Colors.red,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            MySpacing.height(20),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildStatItem(
                        Icons.local_taxi_rounded,
                        'Courses',
                        controller.todayRides.value.toString(),
                        contentTheme.primary,
                      )),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: Obx(() => _buildStatItem(
                        Icons.payments_rounded,
                        'Gains',
                        '${controller.todayEarnings.value.toStringAsFixed(0)} F',
                        const Color(0xFF22C55E),
                      )),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: Obx(() => _buildStatItem(
                        Icons.access_time_rounded,
                        'Temps',
                        '${controller.onlineTime.value}h',
                        Colors.orange,
                      )),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 56.h,
      color: contentTheme.onBackground.withOpacity(0.08),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        MySpacing.height(8),
        MyText.bodySmall(
          label,
          fontSize: 11.sp,
          color: contentTheme.onBackground.withOpacity(0.5),
        ),
        MySpacing.height(3),
        MyText.bodyMedium(
          value,
          fontWeight: 700,
          fontSize: 15.sp,
          color: contentTheme.onBackground,
        ),
      ],
    );
  }

  Widget _buildRideRequestDialog() {
    return Obx(() {
      if (!controller.hasNewRideRequest.value) return const SizedBox.shrink();

      return Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: contentTheme.background,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with circular timer
                _buildDialogHeader(),
                // Content
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                  child: Column(
                    children: [
                      MySpacing.height(4),
                      // Trip info
                      _buildTripInfo(),
                      MySpacing.height(16),
                      // Trip metrics
                      _buildTripMetrics(),
                      MySpacing.height(24),
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
        ),
      );
    });
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_taxi_rounded, size: 28, color: Colors.white),
          ),
          MySpacing.width(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium(
                  'Nouvelle course !',
                  fontWeight: 700,
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
                MyText.bodySmall(
                  'Répondez avant expiration du délai',
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
          // Circular countdown timer
          Obx(() => SizedBox(
                width: 52.w,
                height: 52.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52.w,
                      height: 52.w,
                      child: CircularProgressIndicator(
                        value: controller.requestTimer.value / 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    MyText.bodyMedium(
                      '${controller.requestTimer.value}',
                      fontWeight: 700,
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: contentTheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            icon: Icons.my_location_rounded,
            iconColor: Colors.green,
            label: 'Départ',
            address: controller.ridePickupAddress.value,
          ),
          Padding(
            padding: EdgeInsets.only(left: 11.w),
            child: Column(
              children: List.generate(
                3,
                (i) => Container(
                  width: 1.5.w,
                  height: 5.h,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                  color: contentTheme.onBackground.withOpacity(0.2),
                ),
              ),
            ),
          ),
          _buildAddressRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red,
            label: 'Arrivée',
            address: controller.rideDestinationAddress.value,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        MySpacing.width(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodySmall(
                label,
                fontSize: 11.sp,
                color: contentTheme.onBackground.withOpacity(0.5),
              ),
              MyText.bodyMedium(
                address,
                fontWeight: 600,
                fontSize: 13.sp,
                color: contentTheme.onBackground,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            Icons.straighten_rounded,
            '${controller.rideDistance.value.toStringAsFixed(1)} km',
            'Distance',
            contentTheme.primary,
          ),
        ),
        MySpacing.width(10),
        Expanded(
          child: _buildMetricCard(
            Icons.access_time_rounded,
            '${controller.rideDuration.value} min',
            'Durée',
            Colors.orange,
          ),
        ),
        MySpacing.width(10),
        Expanded(
          child: _buildMetricCard(
            Icons.payments_rounded,
            '${controller.ridePrice.value.toStringAsFixed(0)} F',
            'Gain',
            const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          MySpacing.height(6),
          MyText.bodyMedium(
            value,
            fontWeight: 700,
            fontSize: 14.sp,
            color: contentTheme.onBackground,
          ),
          MyText.bodySmall(
            label,
            fontSize: 10.sp,
            color: contentTheme.onBackground.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Refuser',
            icon: Icons.close_rounded,
            color: Colors.red,
            filled: false,
            onTap: () => controller.declineRide(),
          ),
        ),
        MySpacing.width(12),
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: 'Accepter',
            icon: Icons.check_rounded,
            color: const Color(0xFF22C55E),
            filled: true,
            onTap: () => controller.acceptRide(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : color, size: 18),
              MySpacing.width(6),
              MyText.bodyMedium(
                label,
                fontWeight: 700,
                fontSize: 15.sp,
                color: filled ? Colors.white : color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
