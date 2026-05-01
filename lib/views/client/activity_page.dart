import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with UIMixin {
  final List<Map<String, dynamic>> _activities = [
    {
      'type': 'promo',
      'title': 'Code promo disponible',
      'description': 'Utilisez FIRST10 pour 10% de réduction sur votre prochaine course',
      'icon': Icons.local_offer_rounded,
      'color': Colors.orange,
      'group': "Aujourd'hui",
      'time': 'Il y a 2h',
      'read': false,
    },
    {
      'type': 'ride',
      'title': 'Course terminée',
      'description': 'Marché Central → Université de Ouagadougou',
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF22C55E),
      'group': "Aujourd'hui",
      'time': 'Il y a 5h',
      'read': false,
    },
    {
      'type': 'payment',
      'title': 'Paiement effectué',
      'description': '2 500 FCFA via Orange Money',
      'icon': Icons.payments_rounded,
      'color': Colors.blue,
      'group': 'Hier',
      'time': 'Hier à 14h30',
      'read': true,
    },
    {
      'type': 'ride',
      'title': 'Course terminée',
      'description': 'Aéroport International → Centre-ville',
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF22C55E),
      'group': 'Hier',
      'time': 'Hier à 10h15',
      'read': true,
    },
    {
      'type': 'info',
      'title': 'Nouvelle fonctionnalité',
      'description': 'Vous pouvez maintenant programmer vos courses à l\'avance',
      'icon': Icons.new_releases_rounded,
      'color': Colors.purple,
      'group': 'Plus tôt',
      'time': 'Il y a 3 jours',
      'read': true,
    },
    {
      'type': 'promo',
      'title': 'Offre spéciale week-end',
      'description': '15% de réduction tous les samedis et dimanches',
      'icon': Icons.local_offer_rounded,
      'color': Colors.orange,
      'group': 'Plus tôt',
      'time': 'Il y a 5 jours',
      'read': true,
    },
  ];

  List<String> get _groups => _activities
      .map((a) => a['group'] as String)
      .toSet()
      .toList();

  int get _unreadCount => _activities.where((a) => !(a['read'] as bool)).length;

  void _markAllAsRead() {
    setState(() {
      for (final a in _activities) {
        a['read'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _activities[index]['read'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildGroupedList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyText.titleLarge(
                      'Activité',
                      fontWeight: 800,
                      fontSize: 26.sp,
                      color: contentTheme.onBackground,
                    ),
                    if (_unreadCount > 0) ...[
                      MySpacing.width(10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: contentTheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: MyText.bodySmall(
                          '$_unreadCount',
                          fontWeight: 700,
                          fontSize: 11.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                MyText.bodySmall(
                  _unreadCount > 0
                      ? '$_unreadCount notification${_unreadCount > 1 ? 's' : ''} non lue${_unreadCount > 1 ? 's' : ''}'
                      : 'Tout est à jour',
                  fontSize: 13.sp,
                  color: contentTheme.onBackground.withOpacity(0.5),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: MyText.bodySmall(
                  'Tout lire',
                  fontWeight: 600,
                  fontSize: 13.sp,
                  color: contentTheme.primary,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildGroupedList() {
    final groups = _groups;
    int globalIndex = 0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final groupActivities = _activities
            .asMap()
            .entries
            .where((e) => e.value['group'] == group)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(group),
            ...groupActivities.map((entry) {
              final activity = entry.value;
              final activityIndex = entry.key;
              final animDelay = (globalIndex++ * 60).ms;
              return _buildActivityCard(activity, activityIndex, animDelay);
            }),
            MySpacing.height(8),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(String group) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, bottom: 10.h),
      child: Row(
        children: [
          MyText.bodyMedium(
            group,
            fontWeight: 700,
            fontSize: 13.sp,
            color: contentTheme.onBackground.withOpacity(0.4),
          ),
          MySpacing.width(10),
          Expanded(
            child: Divider(
              color: contentTheme.onBackground.withOpacity(0.08),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    Map<String, dynamic> activity,
    int activityIndex,
    Duration delay,
  ) {
    final isUnread = !(activity['read'] as bool);
    final Color color = activity['color'] as Color;

    return GestureDetector(
      onTap: () => _markAsRead(activityIndex),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isUnread
              ? contentTheme.primary.withOpacity(0.03)
              : contentTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnread
                ? contentTheme.primary.withOpacity(0.2)
                : contentTheme.onBackground.withOpacity(0.08),
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: color,
                  size: 22,
                ),
              ),
              MySpacing.width(14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MyText.bodyMedium(
                            activity['title'],
                            fontWeight: isUnread ? 700 : 600,
                            fontSize: 14.sp,
                            color: contentTheme.onBackground,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(left: 8.w, top: 2.h),
                            decoration: BoxDecoration(
                              color: contentTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    MySpacing.height(4),
                    MyText.bodySmall(
                      activity['description'],
                      fontSize: 12.sp,
                      color: contentTheme.onBackground.withOpacity(0.6),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MySpacing.height(6),
                    MyText.bodySmall(
                      activity['time'],
                      fontSize: 11.sp,
                      color: contentTheme.onBackground.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: delay).slideX(begin: 0.1, end: 0),
    );
  }
}
