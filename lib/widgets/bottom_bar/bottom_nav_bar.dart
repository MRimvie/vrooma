import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../helpers/utils/ui_mixins.dart';

class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.home,
        label: 'Accueil',
        index: 0,
      ),
      _NavItem(
        icon: Icons.history,
        label: 'Historique',
        index: 1,
      ),
      _NavItem(
        icon: Icons.local_activity,
        label: 'Activité',
        index: 2,
      ),
      _NavItem(
        icon: Icons.account_circle,
        label: 'Profil',
        index: 3,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = widget.currentIndex == item.index;
              return Expanded(
                child: InkWell(
                  onTap: () => widget.onTabChange(item.index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? contentTheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isActive
                              ? contentTheme.primary
                              : contentTheme.onBackground.withOpacity(0.5),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isActive
                                ? contentTheme.primary
                                : contentTheme.onBackground.withOpacity(0.6),
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ));
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
