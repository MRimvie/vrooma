import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import '../../controller/client/ride_tracking_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';
import '../../models/ride_model.dart';

class RideTrackingPage extends StatefulWidget {
  const RideTrackingPage({Key? key}) : super(key: key);

  @override
  State<RideTrackingPage> createState() => _RideTrackingPageState();
}

class _RideTrackingPageState extends State<RideTrackingPage> with UIMixin {
  final RideTrackingController controller = Get.put(RideTrackingController());
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Map
  // ---------------------------------------------------------------------------

  Widget _buildMap() {
    return Obx(() => FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(12.3714, -1.5197),
            initialZoom: 13.0,
            onMapReady: () => controller.onMapCreated(_mapController),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.solidar.vrooma',
            ),
            PolylineLayer(polylines: controller.polylines.toList()),
            MarkerLayer(markers: controller.markers.toList()),
          ],
        ));
  }

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------

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
              onTap: _showCancelDialog,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.arrow_back_ios_new,
                    color: contentTheme.primary, size: 20),
              ),
            ),
            MySpacing.width(12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        _getStatusText(controller.rideStatus.value),
                        fontSize: 12.sp,
                        color: _getStatusColor(controller.rideStatus.value),
                        fontWeight: 600,
                      ),
                      MyText.bodyMedium(
                        controller.estimatedTime.value,
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: contentTheme.onBackground,
                      ),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: controller.shareRide,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.share_outlined,
                    color: contentTheme.primary, size: 20),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom sheet dispatcher
  // ---------------------------------------------------------------------------

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 380.h),
        child: Container(
          decoration: BoxDecoration(
            color: contentTheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Obx(() {
            final status = controller.rideStatus.value;
            if (status == RideStatus.pending) return _buildSearchingDriver();
            if (status == RideStatus.accepted ||
                status == RideStatus.driverArriving) {
              return _buildDriverInfo();
            }
            if (status == RideStatus.inProgress) return _buildRideInProgress();
            if (status == RideStatus.completed) return _buildRideCompleted();
            return const SizedBox.shrink();
          }),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 1, end: 0),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Searching driver
  // ---------------------------------------------------------------------------

  Widget _buildSearchingDriver() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: contentTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, size: 36, color: contentTheme.primary),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 2000.ms,
                color: contentTheme.primary.withOpacity(0.3),
              ),
          MySpacing.height(16),
          MyText.titleMedium(
            'Recherche d\'un chauffeur...',
            fontWeight: 700,
            fontSize: 18.sp,
            color: contentTheme.onBackground,
            textAlign: TextAlign.center,
          ),
          MySpacing.height(6),
          MyText.bodyMedium(
            'Nous recherchons le meilleur chauffeur pour vous',
            fontSize: 13.sp,
            color: contentTheme.onBackground.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
          MySpacing.height(18),
          _buildCancelButton(),
          MySpacing.height(4),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Driver info (accepted + driverArriving)
  // ---------------------------------------------------------------------------

  Widget _buildDriverInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Driver row — tappable to see profile
              GestureDetector(
                onTap: _showDriverProfileSheet,
                child: Row(
                  children: [
                    // Avatar with hero-tap indicator
                    Stack(
                      children: [
                        Container(
                          width: 58.w,
                          height: 58.w,
                          decoration: BoxDecoration(
                            color: contentTheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: MyText.titleMedium(
                              _driverInitials(controller.driverName.value),
                              fontWeight: 700,
                              fontSize: 20.sp,
                              color: contentTheme.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: contentTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: contentTheme.background, width: 1.5),
                            ),
                            child: const Icon(Icons.info_outline_rounded,
                                size: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    MySpacing.width(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyLarge(
                            controller.driverName.value,
                            fontWeight: 700,
                            fontSize: 17.sp,
                            color: contentTheme.onBackground,
                          ),
                          MySpacing.height(4),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 15, color: Colors.amber),
                              MySpacing.width(3),
                              MyText.bodyMedium(
                                controller.driverRating.value
                                    .toStringAsFixed(1),
                                fontWeight: 600,
                                fontSize: 13.sp,
                                color: contentTheme.onBackground,
                              ),
                              MySpacing.width(8),
                              Flexible(
                                child: MyText.bodySmall(
                                  '${controller.vehicleModel.value} • ${controller.vehiclePlate.value}',
                                  fontSize: 12.sp,
                                  color:
                                      contentTheme.onBackground.withOpacity(0.6),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Contact buttons
                    GestureDetector(
                      onTap: controller.callDriver,
                      child: Container(
                        padding: EdgeInsets.all(11.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.phone_rounded,
                            color: Colors.green, size: 22),
                      ),
                    ),
                    MySpacing.width(8),
                    GestureDetector(
                      onTap: controller.messageDriver,
                      child: Container(
                        padding: EdgeInsets.all(11.w),
                        decoration: BoxDecoration(
                          color: contentTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chat_bubble_outline_rounded,
                            color: contentTheme.primary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              MySpacing.height(16),

              // ETA / distance info row
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      Icons.access_time_rounded,
                      'Arrivée dans',
                      controller.driverETA.value,
                    ),
                    Container(
                        width: 1,
                        height: 36.h,
                        color: contentTheme.onBackground.withOpacity(0.1)),
                    _buildInfoItem(
                      Icons.navigation_rounded,
                      'Distance',
                      '${controller.driverDistance.value.toStringAsFixed(1)} km',
                    ),
                  ],
                ),
              ),

              MySpacing.height(14),

              // Confirm boarding button — only visible when driver has arrived
              if (controller.awaitingBoardingConfirmation.value)
                _buildConfirmBoardingButton()
              else
                _buildCancelButton(),
            ],
          )),
    );
  }

  Widget _buildConfirmBoardingButton() {
    return GestureDetector(
      onTap: controller.confirmBoarding,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 22),
            MySpacing.width(10),
            MyText.bodyLarge(
              'Je suis dans le véhicule',
              fontWeight: 700,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.95, 0.95),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // In progress
  // ---------------------------------------------------------------------------

  Widget _buildRideInProgress() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText.titleMedium(
            'Course en cours',
            fontWeight: 700,
            fontSize: 20.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(16),
          Obx(() => Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.rideProgress.value,
                    backgroundColor:
                        contentTheme.onBackground.withOpacity(0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(contentTheme.primary),
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  MySpacing.height(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.bodyMedium(
                        '${(controller.rideProgress.value * 100).toInt()}% complété',
                        fontSize: 13.sp,
                        color: contentTheme.onBackground.withOpacity(0.6),
                      ),
                      MyText.bodyMedium(
                        'Arrivée : ${controller.estimatedArrival.value}',
                        fontSize: 13.sp,
                        fontWeight: 600,
                        color: contentTheme.onBackground,
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Completed
  // ---------------------------------------------------------------------------

  Widget _buildRideCompleted() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 36, color: Colors.green),
              ).animate().scale(duration: 600.ms),
              MySpacing.width(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                      'Course terminée !',
                      fontWeight: 700,
                      fontSize: 18.sp,
                      color: contentTheme.onBackground,
                    ),
                    Obx(() => MyText.bodyLarge(
                          '${controller.finalPrice.value.toStringAsFixed(0)} FCFA',
                          fontWeight: 800,
                          fontSize: 22.sp,
                          color: contentTheme.primary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(18),
          _buildRateDriverButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: contentTheme.primary, size: 22),
        MySpacing.height(6),
        MyText.bodySmall(label,
            fontSize: 11.sp,
            color: contentTheme.onBackground.withOpacity(0.55)),
        MySpacing.height(2),
        MyText.bodyMedium(value,
            fontWeight: 700, fontSize: 14.sp, color: contentTheme.onBackground),
      ],
    );
  }

  Widget _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCancelDialog,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 13.h),
            child: Center(
              child: MyText.bodyMedium(
                'Annuler la course',
                fontWeight: 600,
                fontSize: 15.sp,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateDriverButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            contentTheme.primary,
            contentTheme.primary.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.rateDriver,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: MyText.bodyLarge(
                'Évaluer le chauffeur',
                fontWeight: 700,
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Driver profile bottom sheet
  // ---------------------------------------------------------------------------

  void _showDriverProfileSheet() {
    final pastRides = [
      {
        'from': 'Gounghin',
        'to': 'Université de Ouagadougou',
        'date': 'Il y a 3 jours',
        'price': '2 500 FCFA',
        'rating': 5,
      },
      {
        'from': 'Marché Central',
        'to': 'Aéroport International',
        'date': 'Il y a 2 semaines',
        'price': '4 200 FCFA',
        'rating': 5,
      },
      {
        'from': 'Zone du Bois',
        'to': 'Hôpital Yalgado',
        'date': 'Il y a 1 mois',
        'price': '1 800 FCFA',
        'rating': 4,
      },
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: contentTheme.onBackground.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Avatar + name
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: MyText.titleLarge(
                    _driverInitials(controller.driverName.value),
                    fontWeight: 800,
                    fontSize: 26.sp,
                    color: contentTheme.primary,
                  ),
                ),
              ),
              MySpacing.height(12),
              MyText.titleMedium(
                controller.driverName.value,
                fontWeight: 700,
                fontSize: 20.sp,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final rating = controller.driverRating.value.round();
                  return Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
              ),
              MySpacing.height(4),
              MyText.bodyMedium(
                '${controller.driverRating.value.toStringAsFixed(1)} • ${controller.vehicleModel.value} (${controller.vehiclePlate.value})',
                fontSize: 13.sp,
                color: contentTheme.onBackground.withOpacity(0.6),
              ),

              MySpacing.height(20),

              // Stats row
              Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    _profileStat('187', 'Courses'),
                    _verticalDivider(),
                    _profileStat('4 ans', 'Expérience'),
                    _verticalDivider(),
                    _profileStat('4.8', 'Note moy.'),
                  ],
                ),
              ),

              MySpacing.height(20),

              // Past rides with this client
              Align(
                alignment: Alignment.centerLeft,
                child: MyText.bodyMedium(
                  'Vos courses avec ce chauffeur',
                  fontWeight: 700,
                  fontSize: 14.sp,
                  color: contentTheme.onBackground,
                ),
              ),
              MySpacing.height(10),
              ...pastRides.map((ride) => _buildPastRideItem(ride)),

              MySpacing.height(16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.callDriver();
                      },
                      icon: const Icon(Icons.phone_rounded,
                          color: Colors.green, size: 18),
                      label: MyText.bodyMedium(
                        'Appeler',
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: Colors.green,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  MySpacing.width(12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.messageDriver();
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: Colors.white),
                      label: MyText.bodyMedium(
                        'Message',
                        fontWeight: 600,
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contentTheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _profileStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          MyText.bodyLarge(value,
              fontWeight: 800,
              fontSize: 16.sp,
              color: contentTheme.onBackground),
          MySpacing.height(2),
          MyText.bodySmall(label,
              fontSize: 11.sp,
              color: contentTheme.onBackground.withOpacity(0.55)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 36.h,
      color: contentTheme.onBackground.withOpacity(0.1),
    );
  }

  Widget _buildPastRideItem(Map<String, dynamic> ride) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: contentTheme.onBackground.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.directions_car_rounded,
                  color: contentTheme.primary, size: 18),
            ),
            MySpacing.width(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    '${ride['from']} → ${ride['to']}',
                    fontWeight: 600,
                    fontSize: 13.sp,
                    color: contentTheme.onBackground,
                    overflow: TextOverflow.ellipsis,
                  ),
                  MySpacing.height(2),
                  MyText.bodySmall(
                    ride['date'] as String,
                    fontSize: 11.sp,
                    color: contentTheme.onBackground.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText.bodyMedium(
                  ride['price'] as String,
                  fontWeight: 700,
                  fontSize: 13.sp,
                  color: contentTheme.primary,
                ),
                MySpacing.height(2),
                Row(
                  children: List.generate(
                    ride['rating'] as int,
                    (_) => const Icon(Icons.star_rounded,
                        size: 11, color: Colors.amber),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: contentTheme.background,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: MyText.titleMedium(
          'Annuler la course ?',
          fontWeight: 700,
          fontSize: 18.sp,
          color: contentTheme.onBackground,
        ),
        content: MyText.bodyMedium(
          'Êtes-vous sûr de vouloir annuler cette course ?',
          fontSize: 14.sp,
          color: contentTheme.onBackground.withOpacity(0.65),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: MyText.bodyMedium('Non',
                fontSize: 14.sp,
                color: contentTheme.onBackground.withOpacity(0.6)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelRide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: MyText.bodyMedium('Oui, annuler',
                fontWeight: 700, fontSize: 14.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _driverInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return 'Recherche en cours...';
      case RideStatus.accepted:
        return 'Chauffeur en route';
      case RideStatus.driverArriving:
        return 'Votre chauffeur est là !';
      case RideStatus.inProgress:
        return 'Course en cours';
      case RideStatus.completed:
        return 'Course terminée';
      case RideStatus.cancelled:
        return 'Course annulée';
    }
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return Colors.orange;
      case RideStatus.accepted:
        return Colors.blue;
      case RideStatus.driverArriving:
        return Colors.green;
      case RideStatus.inProgress:
        return contentTheme.primary;
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
    }
  }
}
