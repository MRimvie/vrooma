import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../helpers/my_widgets/my_spacing.dart';
import '../../helpers/my_widgets/my_text.dart';
import '../../helpers/utils/ui_mixins.dart';
import '../../services/mock_auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with UIMixin {
  final MockAuthService _auth = Get.find<MockAuthService>();
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  String get _initials {
    final parts = _auth.currentUserName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _auth.currentUserName.isNotEmpty
        ? _auth.currentUserName[0].toUpperCase()
        : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    MySpacing.height(4),
                    _buildProfileCard(),
                    MySpacing.height(16),
                    _buildWalletCard(),
                    MySpacing.height(16),
                    _buildStatsRow(),
                    MySpacing.height(20),
                    _buildMenuSection(),
                    MySpacing.height(20),
                    _buildLogoutButton(),
                    MySpacing.height(40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText.titleLarge(
            'Mon Profil',
            fontWeight: 800,
            fontSize: 24.sp,
            color: contentTheme.onBackground,
          ),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: contentTheme.onBackground.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: contentTheme.onBackground,
                ),
              ),
              if (_auth.unreadNotifications > 0)
                Positioned(
                  top: 6.h,
                  right: 6.w,
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
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [contentTheme.primary, contentTheme.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: contentTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: MyText.titleMedium(
                    _initials,
                    fontWeight: 700,
                    fontSize: 22.sp,
                    color: contentTheme.primary,
                  ),
                ),
              ),
              MySpacing.width(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                      _auth.currentUserName,
                      fontWeight: 700,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                    MySpacing.height(2),
                    MyText.bodySmall(
                      _auth.currentUserEmail.isNotEmpty
                          ? _auth.currentUserEmail
                          : _auth.currentUserPhone,
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    MySpacing.height(6),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 12, color: Colors.white.withOpacity(0.9)),
                          MySpacing.width(4),
                          MyText.bodySmall(
                            _auth.currentUserPhone,
                            fontSize: 11.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showEditProfileSheet,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          MySpacing.height(16),
          Row(
            children: [
              _buildBadge(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                label: _auth.userRating.toStringAsFixed(1),
                sublabel: 'Note',
              ),
              MySpacing.width(10),
              _buildBadge(
                icon: Icons.local_offer_rounded,
                iconColor: Colors.greenAccent,
                label: '${_auth.loyaltyPoints}',
                sublabel: 'Points',
              ),
              MySpacing.width(10),
              _buildBadge(
                icon: Icons.verified_rounded,
                iconColor: Colors.lightBlueAccent,
                label: 'Vérifié',
                sublabel: 'Compte',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor),
            MySpacing.height(4),
            MyText.bodyMedium(
              label,
              fontWeight: 700,
              fontSize: 13.sp,
              color: Colors.white,
            ),
            MyText.bodySmall(
              sublabel,
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    final balance = _auth.walletBalance;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: contentTheme.onBackground.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: contentTheme.onBackground.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: contentTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: contentTheme.primary,
              size: 26,
            ),
          ),
          MySpacing.width(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodySmall(
                  'Solde portefeuille',
                  fontSize: 12.sp,
                  color: contentTheme.onBackground.withOpacity(0.55),
                ),
                MySpacing.height(2),
                MyText.titleMedium(
                  '${balance.toStringAsFixed(0)} FCFA',
                  fontWeight: 800,
                  fontSize: 20.sp,
                  color: contentTheme.onBackground,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showTopUpSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: contentTheme.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: MyText.bodyMedium(
                'Recharger',
                fontWeight: 700,
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: contentTheme.onBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.directions_car_rounded,
            '${_auth.totalRides}',
            'Courses',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.emoji_events_rounded,
            '${_auth.loyaltyPoints}',
            'Points fidélité',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.calendar_today_rounded,
            _auth.memberSince,
            'Membre depuis',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: contentTheme.primary),
          MySpacing.height(6),
          MyText.bodyMedium(
            value,
            fontWeight: 700,
            fontSize: 14.sp,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(2),
          MyText.bodySmall(
            label,
            fontSize: 11.sp,
            textAlign: TextAlign.center,
            color: contentTheme.onBackground.withOpacity(0.55),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 44.h,
      color: contentTheme.onBackground.withOpacity(0.1),
    );
  }

  Widget _buildMenuSection() {
    final items = [
      {
        'icon': Icons.payment_rounded,
        'title': 'Moyens de paiement',
        'subtitle': 'Gérer vos cartes et comptes',
        'onTap': () {},
      },
      {
        'icon': Icons.local_offer_rounded,
        'title': 'Codes promo',
        'subtitle': 'Voir vos codes disponibles',
        'onTap': () {},
      },
      {
        'icon': Icons.history_rounded,
        'title': 'Historique de paiements',
        'subtitle': 'Transactions et recharges',
        'onTap': () {},
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Aide & Support',
        'subtitle': 'FAQ et assistance',
        'onTap': () {},
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Confidentialité',
        'subtitle': 'Paramètres de confidentialité',
        'onTap': () {},
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'À propos',
        'subtitle': 'Solidar VTC • v1.0.0',
        'onTap': () {},
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: contentTheme.onBackground.withOpacity(0.08)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? Radius.circular(16.r) : Radius.zero,
                    bottom: i == items.length - 1
                        ? Radius.circular(16.r)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: BoxDecoration(
                            color: contentTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: contentTheme.primary,
                            size: 20,
                          ),
                        ),
                        MySpacing.width(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.bodyMedium(
                                item['title'] as String,
                                fontWeight: 600,
                                fontSize: 14.sp,
                                color: contentTheme.onBackground,
                              ),
                              MySpacing.height(1),
                              MyText.bodySmall(
                                item['subtitle'] as String,
                                fontSize: 11.sp,
                                color: contentTheme.onBackground
                                    .withOpacity(0.55),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: contentTheme.onBackground.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 56.w,
                  color: contentTheme.onBackground.withOpacity(0.07),
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            MySpacing.width(10),
            MyText.bodyLarge(
              'Se déconnecter',
              fontWeight: 700,
              fontSize: 15.sp,
              color: Colors.red,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  // --- Actions ---

  void _showEditProfileSheet() {
    final nameCtrl =
        TextEditingController(text: _auth.currentUserName);
    final emailCtrl =
        TextEditingController(text: _auth.currentUserEmail);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: contentTheme.onBackground.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            MyText.titleMedium(
              'Modifier le profil',
              fontWeight: 700,
              fontSize: 18.sp,
              color: contentTheme.onBackground,
            ),
            MySpacing.height(24),
            _sheetTextField(nameCtrl, 'Nom complet', Icons.person_outline),
            MySpacing.height(16),
            _sheetTextField(emailCtrl, 'Email', Icons.email_outlined,
                type: TextInputType.emailAddress),
            MySpacing.height(24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _auth.updateProfile(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                  );
                  Get.back();
                  _refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: MyText.bodyLarge(
                  'Enregistrer',
                  fontWeight: 700,
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTopUpSheet() {
    const amounts = [5000.0, 10000.0, 25000.0, 50000.0];
    double selected = 10000.0;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: contentTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: contentTheme.onBackground.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              MyText.titleMedium(
                'Recharger le portefeuille',
                fontWeight: 700,
                fontSize: 18.sp,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(6),
              MyText.bodyMedium(
                'Solde actuel : ${_auth.walletBalance.toStringAsFixed(0)} FCFA',
                fontSize: 13.sp,
                color: contentTheme.onBackground.withOpacity(0.55),
              ),
              MySpacing.height(24),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: amounts.map((amount) {
                  final isSelected = selected == amount;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selected = amount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? contentTheme.primary
                            : contentTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? contentTheme.primary
                              : contentTheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: MyText.bodyMedium(
                        '${amount.toStringAsFixed(0)} F',
                        fontWeight: 700,
                        fontSize: 14.sp,
                        color: isSelected
                            ? Colors.white
                            : contentTheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              MySpacing.height(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _auth.topUpWallet(selected);
                    Get.back();
                    _refresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: contentTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText.bodyLarge(
                    'Payer ${selected.toStringAsFixed(0)} FCFA',
                    fontWeight: 700,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: contentTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: MyText.titleMedium(
          'Se déconnecter ?',
          fontWeight: 700,
          fontSize: 18.sp,
          color: contentTheme.onBackground,
        ),
        content: MyText.bodyMedium(
          'Vous devrez vous reconnecter pour accéder à l\'application.',
          fontSize: 14.sp,
          color: contentTheme.onBackground.withOpacity(0.65),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: MyText.bodyMedium(
              'Annuler',
              fontSize: 14.sp,
              color: contentTheme.onBackground.withOpacity(0.6),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _auth.signOut();
              Get.offAllNamed('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: MyText.bodyMedium(
              'Déconnecter',
              fontWeight: 700,
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: contentTheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: contentTheme.onBackground.withOpacity(0.1)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style:
            TextStyle(fontSize: 15.sp, color: contentTheme.onBackground),
        decoration: InputDecoration(
          prefixIcon: Icon(icon,
              color: contentTheme.primary.withOpacity(0.7), size: 20),
          hintText: hint,
          hintStyle: TextStyle(
            color: contentTheme.onBackground.withOpacity(0.35),
            fontSize: 15.sp,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
