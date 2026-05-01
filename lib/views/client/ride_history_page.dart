import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/client/ride_history_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';
import '../../models/ride_model.dart';
import 'package:intl/intl.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({Key? key}) : super(key: key);

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> with UIMixin {
  final RideHistoryController controller = Get.put(RideHistoryController());
  int _selectedFilter = 0;
  final List<String> _filters = ['Toutes', 'Terminées', 'Annulées'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSummaryCard(),
            _buildFilterTabs(),
            Expanded(child: _buildRideList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleLarge(
                  'Historique',
                  fontWeight: 800,
                  fontSize: 26.sp,
                  color: contentTheme.onBackground,
                ),
                MyText.bodySmall(
                  'Vos courses passées',
                  fontSize: 13.sp,
                  color: contentTheme.onBackground.withOpacity(0.5),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.loadRides(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: contentTheme.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final completed = controller.rides
          .where((r) => r.status == RideStatus.completed)
          .length;
      final totalSpent = controller.rides
          .where((r) => r.status == RideStatus.completed)
          .fold<double>(0, (sum, r) => sum + (r.finalPrice ?? r.estimatedPrice));

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              contentTheme.primary,
              contentTheme.primary.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: contentTheme.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(
                    'Courses effectuées',
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  MySpacing.height(6),
                  MyText.titleLarge(
                    '$completed',
                    fontWeight: 800,
                    fontSize: 34.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: 1.w,
              height: 48.h,
              color: Colors.white.withOpacity(0.3),
            ),
            MySpacing.width(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(
                    'Total dépensé',
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  MySpacing.height(6),
                  MyText.titleMedium(
                    '${totalSpent.toStringAsFixed(0)} F',
                    fontWeight: 800,
                    fontSize: 22.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_taxi_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
    });
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? contentTheme.primary
                      : contentTheme.onBackground.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: MyText.bodySmall(
                    label,
                    fontWeight: 600,
                    fontSize: 13.sp,
                    color: isSelected
                        ? Colors.white
                        : contentTheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildRideList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: contentTheme.primary,
            strokeWidth: 2.5,
          ),
        );
      }

      final filtered = _getFilteredRides();

      if (filtered.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadRides,
        color: contentTheme.primary,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => MySpacing.height(12),
          itemBuilder: (context, index) {
            return _buildRideCard(filtered[index], index);
          },
        ),
      );
    });
  }

  List<RideModel> _getFilteredRides() {
    switch (_selectedFilter) {
      case 1:
        return controller.rides
            .where((r) => r.status == RideStatus.completed)
            .toList();
      case 2:
        return controller.rides
            .where((r) => r.status == RideStatus.cancelled)
            .toList();
      default:
        return controller.rides.toList();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: contentTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 60,
              color: contentTheme.primary,
            ),
          ),
          MySpacing.height(24),
          MyText.titleMedium(
            'Aucune course',
            fontWeight: 700,
            fontSize: 20.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(8),
          MyText.bodyMedium(
            'Vos courses apparaîtront ici\naprès votre première réservation.',
            fontSize: 14.sp,
            color: contentTheme.onBackground.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildRideCard(RideModel ride, int index) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');
    return Container(
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: contentTheme.onBackground.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewRideDetails(ride),
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(ride.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: _getStatusColor(ride.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          MySpacing.width(6),
                          MyText.bodySmall(
                            _getStatusText(ride.status),
                            fontWeight: 600,
                            fontSize: 12.sp,
                            color: _getStatusColor(ride.status),
                          ),
                        ],
                      ),
                    ),
                    MyText.bodySmall(
                      dateFormat.format(ride.createdAt),
                      fontSize: 11.sp,
                      color: contentTheme.onBackground.withOpacity(0.45),
                    ),
                  ],
                ),
                MySpacing.height(16),
                // Route visual
                _buildRouteVisual(ride),
                MySpacing.height(14),
                Divider(
                  height: 1,
                  color: contentTheme.onBackground.withOpacity(0.07),
                ),
                MySpacing.height(12),
                // Bottom info row
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.straighten_rounded,
                      '${ride.distance.toStringAsFixed(1)} km',
                    ),
                    MySpacing.width(16),
                    _buildInfoChip(
                      Icons.access_time_rounded,
                      '${ride.estimatedDuration} min',
                    ),
                    const Spacer(),
                    MyText.bodyLarge(
                      '${(ride.finalPrice ?? ride.estimatedPrice).toStringAsFixed(0)} FCFA',
                      fontWeight: 700,
                      fontSize: 15.sp,
                      color: contentTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 70).ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildRouteVisual(RideModel ride) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dots + line
        Column(
          children: [
            Container(
              width: 11.w,
              height: 11.w,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2.w,
              height: 22.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Colors.red],
                ),
              ),
            ),
            Container(
              width: 11.w,
              height: 11.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        MySpacing.width(14),
        // Addresses
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium(
                ride.pickupLocation.address,
                fontSize: 13.sp,
                fontWeight: 500,
                color: contentTheme.onBackground,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              MySpacing.height(18),
              MyText.bodyMedium(
                ride.destinationLocation.address,
                fontSize: 13.sp,
                fontWeight: 500,
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: contentTheme.onBackground.withOpacity(0.45)),
        MySpacing.width(4),
        MyText.bodySmall(
          text,
          fontSize: 12.sp,
          color: contentTheme.onBackground.withOpacity(0.55),
        ),
      ],
    );
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return 'Terminée';
      case RideStatus.cancelled:
        return 'Annulée';
      case RideStatus.inProgress:
        return 'En cours';
      default:
        return 'En attente';
    }
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
      case RideStatus.inProgress:
        return contentTheme.primary;
      default:
        return Colors.orange;
    }
  }
}
