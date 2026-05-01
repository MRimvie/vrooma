import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class SearchLocationPage extends StatefulWidget {
  const SearchLocationPage({Key? key}) : super(key: key);

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> with UIMixin {
  final TextEditingController searchController = TextEditingController();
  final String title = Get.arguments?['title'] ?? 'Rechercher un lieu';
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _allSuggestions = [
    {'name': 'Place des Nations Unies', 'address': 'Centre-ville, Ouagadougou', 'lat': 12.3714, 'lng': -1.5197},
    {'name': 'Marché Central (Rood Wooko)', 'address': 'Gounghin, Ouagadougou', 'lat': 12.3686, 'lng': -1.5275},
    {'name': 'Université Ouaga 1', 'address': 'Tanghin, Ouagadougou', 'lat': 12.3989, 'lng': -1.5089},
    {'name': 'Aéroport International Thomas Sankara', 'address': 'Ouagadougou', 'lat': 12.3532, 'lng': -1.5124},
    {'name': 'Stade du 4 Août', 'address': 'Gounghin, Ouagadougou', 'lat': 12.3650, 'lng': -1.5350},
    {'name': 'Hôpital Yalgado Ouédraogo', 'address': 'Ouagadougou', 'lat': 12.3580, 'lng': -1.5280},
    {'name': 'Hôtel Azalaï Indépendance', 'address': 'Avenue Kwame Nkrumah, Ouagadougou', 'lat': 12.3640, 'lng': -1.5210},
    {'name': 'ZACA (Zone d\'Activités Commerciales)', 'address': 'Ouagadougou', 'lat': 12.3700, 'lng': -1.5150},
  ];

  final List<Map<String, dynamic>> _favoriteLocations = [
    {'name': 'Maison', 'address': 'Gounghin, Ouagadougou', 'lat': 12.3714, 'lng': -1.5197, 'icon': Icons.home_rounded},
    {'name': 'Bureau', 'address': 'Avenue Kwame Nkrumah, Ouagadougou', 'lat': 12.3686, 'lng': -1.5275, 'icon': Icons.work_rounded},
  ];

  List<Map<String, dynamic>> _filteredSuggestions = [];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _allSuggestions;
    searchController.addListener(() {
      final hasText = searchController.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
      _filterSuggestions(searchController.text);
    });
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = _allSuggestions;
      } else {
        _filteredSuggestions = _allSuggestions.where((location) {
          return location['name'].toLowerCase().contains(query.toLowerCase()) ||
              location['address'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    Get.back(result: location);
  }

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: contentTheme.onBackground.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: contentTheme.onBackground,
              ),
            ),
          ),
          MySpacing.width(14),
          Expanded(
            child: MyText.titleMedium(
              title,
              fontWeight: 700,
              fontSize: 18.sp,
              color: contentTheme.onBackground,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: contentTheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _focusNode.hasFocus
              ? contentTheme.primary.withOpacity(0.4)
              : contentTheme.onBackground.withOpacity(0.1),
          width: _focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: contentTheme.primary, size: 22),
          MySpacing.width(12),
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: _focusNode,
              autofocus: true,
              style: TextStyle(fontSize: 15.sp, color: contentTheme.onBackground),
              decoration: InputDecoration(
                hintText: 'Rechercher une adresse...',
                hintStyle: TextStyle(
                  color: contentTheme.onBackground.withOpacity(0.35),
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              onChanged: _filterSuggestions,
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                searchController.clear();
                _filterSuggestions('');
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: contentTheme.onBackground.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: contentTheme.onBackground.withOpacity(0.6),
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      children: [
        // Favorites section (only when not searching)
        if (!_hasText) ...[
          _buildSectionHeader('Lieux enregistrés', Icons.bookmark_rounded),
          ..._favoriteLocations.asMap().entries.map(
                (e) => _buildFavoriteItem(e.value, e.key),
              ),
          MySpacing.height(8),
          _buildSectionHeader('Lieux populaires', Icons.trending_up_rounded),
        ] else if (_filteredSuggestions.isEmpty) ...[
          _buildEmptyState(),
        ],
        // Suggestions list
        if (_filteredSuggestions.isNotEmpty)
          ..._filteredSuggestions.asMap().entries.map(
                (e) => _buildLocationItem(e.value, e.key),
              ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 15, color: contentTheme.onBackground.withOpacity(0.4)),
          MySpacing.width(6),
          MyText.bodyMedium(
            title,
            fontWeight: 700,
            fontSize: 12.sp,
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

  Widget _buildFavoriteItem(Map<String, dynamic> location, int index) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: contentTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: contentTheme.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                location['icon'] as IconData,
                color: contentTheme.primary,
                size: 18,
              ),
            ),
            MySpacing.width(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    location['name'],
                    fontWeight: 700,
                    fontSize: 14.sp,
                    color: contentTheme.onBackground,
                  ),
                  MyText.bodySmall(
                    location['address'],
                    fontSize: 12.sp,
                    color: contentTheme.onBackground.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              size: 16,
              color: contentTheme.primary.withOpacity(0.5),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location, int index) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: contentTheme.onBackground.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: contentTheme.onBackground.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: contentTheme.onBackground.withOpacity(0.5),
                size: 20,
              ),
            ),
            MySpacing.width(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    location['name'],
                    fontWeight: 600,
                    fontSize: 14.sp,
                    color: contentTheme.onBackground,
                  ),
                  MySpacing.height(3),
                  MyText.bodySmall(
                    location['address'],
                    fontSize: 12.sp,
                    color: contentTheme.onBackground.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: contentTheme.onBackground.withOpacity(0.25),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: contentTheme.onBackground.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: contentTheme.onBackground.withOpacity(0.3),
            ),
          ),
          MySpacing.height(16),
          MyText.bodyMedium(
            'Aucun résultat',
            fontWeight: 600,
            fontSize: 16.sp,
            color: contentTheme.onBackground.withOpacity(0.5),
          ),
          MySpacing.height(6),
          MyText.bodySmall(
            'Essayez un autre terme de recherche',
            fontSize: 13.sp,
            color: contentTheme.onBackground.withOpacity(0.35),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
