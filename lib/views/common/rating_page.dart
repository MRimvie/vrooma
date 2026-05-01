import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/common/rating_controller.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> with UIMixin {
  final RatingController controller = Get.put(RatingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              MySpacing.height(20),
              _buildHeader(),
              MySpacing.height(40),
              _buildRatingSection(),
              MySpacing.height(30),
              _buildTagsSection(),
              MySpacing.height(30),
              _buildCommentSection(),
              MySpacing.height(30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                controller.driverPhoto.value.isNotEmpty
                    ? controller.driverPhoto.value
                    : 'https://via.placeholder.com/150',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        MySpacing.height(16),
        Obx(() => MyText.titleLarge(
              controller.driverName.value,
              fontWeight: 700,
              fontSize: 24.sp,
              color: contentTheme.onBackground,
            )),
        MySpacing.height(8),
        MyText.bodyMedium(
          'Comment s\'est passée votre course ?',
          fontSize: 16.sp,
          color: contentTheme.onBackground.withOpacity(0.6),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: contentTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          MyText.bodyMedium(
            'Votre note',
            fontWeight: 600,
            fontSize: 16.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(16),
          Obx(() => RatingBar.builder(
                initialRating: controller.rating.value,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 50.w,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  controller.rating.value = rating;
                },
              )),
          MySpacing.height(12),
          Obx(() => MyText.headlineMedium(
                controller.rating.value.toStringAsFixed(1),
                fontWeight: 700,
                fontSize: 32.sp,
                color: contentTheme.primary,
              )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Que pouvons-nous améliorer ?',
          fontWeight: 600,
          fontSize: 16.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(16),
        Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.availableTags.map((tag) {
                final isSelected = controller.selectedTags.contains(tag);
                return _buildTag(tag, isSelected);
              }).toList(),
            )),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildTag(String tag, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? contentTheme.primary.withOpacity(0.1)
            : contentTheme.background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected
              ? contentTheme.primary
              : contentTheme.onBackground.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleTag(tag),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: MyText.bodySmall(
              tag,
              fontWeight: 600,
              fontSize: 13.sp,
              color: isSelected
                  ? contentTheme.primary
                  : contentTheme.onBackground.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(
          'Commentaire (optionnel)',
          fontWeight: 600,
          fontSize: 16.sp,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(12),
        Container(
          decoration: BoxDecoration(
            color: contentTheme.background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: contentTheme.onBackground.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller.commentController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 14.sp,
              color: contentTheme.onBackground,
            ),
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience...',
              hintStyle: TextStyle(
                color: contentTheme.onBackground.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildSubmitButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.8)],
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
              onTap: controller.isLoading.value ? null : () => controller.submitRating(),
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Center(
                        child: MyText.bodyLarge(
                          'Envoyer l\'évaluation',
                          fontWeight: 700,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        )).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }
}
