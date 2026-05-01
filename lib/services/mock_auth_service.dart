import 'package:get_storage/get_storage.dart';

class MockAuthService {
  final GetStorage _storage = GetStorage();

  static final Map<String, Map<String, dynamic>> _testAccounts = {
    '70123456': {
      'password': '123456',
      'role': 'client',
      'name': 'Amadou Traoré',
      'email': 'amadou.traore@example.bf',
      'rating': 4.8,
      'totalRides': 23,
      'loyaltyPoints': 460,
      'walletBalance': 15000.0,
      'unreadNotifications': 2,
    },
    '75987654': {
      'password': '123456',
      'role': 'driver',
      'name': 'Fatou Ouédraogo',
      'email': 'fatou.ouedraogo@example.bf',
      'rating': 4.9,
      'totalRides': 187,
      'loyaltyPoints': 1870,
      'walletBalance': 45000.0,
      'unreadNotifications': 5,
    },
    '76543210': {
      'password': 'password',
      'role': 'client',
      'name': 'Ibrahim Sawadogo',
      'email': 'ibrahim.sawadogo@example.bf',
      'rating': 4.6,
      'totalRides': 8,
      'loyaltyPoints': 120,
      'walletBalance': 7500.0,
      'unreadNotifications': 0,
    },
  };

  // --- Auth state ---
  String? get currentUserId => _storage.read('mock_user_id');
  String? get currentUserRole => _storage.read('user_role');
  bool get isAuthenticated => _storage.read('mock_user_id') != null;

  // --- Profile state ---
  String get currentUserName => _storage.read('user_name') ?? 'Utilisateur';
  String get currentUserPhone => _storage.read('user_phone') ?? '';
  String get currentUserEmail => _storage.read('user_email') ?? '';
  double get userRating => (_storage.read('user_rating') ?? 4.8).toDouble();
  int get totalRides => _storage.read('total_rides') ?? 0;
  int get loyaltyPoints => _storage.read('loyalty_points') ?? 0;
  double get walletBalance => (_storage.read('wallet_balance') ?? 0.0).toDouble();
  int get unreadNotifications => _storage.read('unread_notifications') ?? 0;
  String get memberSince => _storage.read('member_since') ?? 'Avr. 2026';

  // --- OTP / Phone auth ---
  Future<void> sendOTP(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final mockVerificationId =
        'mock_verification_${DateTime.now().millisecondsSinceEpoch}';
    onCodeSent(mockVerificationId);
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    await Future.delayed(const Duration(seconds: 1));
    if (smsCode == '123456' || smsCode.length == 6) {
      final mockUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _storage.write('mock_user_id', mockUserId);
      _storage.write('mock_user_phone', '+22670123456');
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'userId': userId,
      'firstName': 'Amadou',
      'lastName': 'Traoré',
      'phone': '+22670123456',
      'email': 'amadou.traore@example.bf',
      'role': 'client',
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };
  }

  Future<void> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _storage.write('mock_user_data', {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    });
  }

  void saveUserLocally(Map<String, dynamic> userData) {
    _storage.write('user_id', userData['userId']);
    _storage.write('mock_user_id', userData['userId']);
    _storage.write('user_role', userData['role']);
    _storage.write('user_name',
        '${userData['firstName']} ${userData['lastName']}');
    _storage.write('user_email', userData['email']);
    _storage.write('user_phone', userData['phone']);
    _storage.write('user_rating', 4.8);
    _storage.write('total_rides', 0);
    _storage.write('loyalty_points', 0);
    _storage.write('wallet_balance', 0.0);
    _storage.write('unread_notifications', 0);
    _storage.write('member_since', _monthYear(DateTime.now()));
  }

  // --- Password login ---
  Future<bool> loginWithPassword({
    required String phone,
    required String password,
    bool rememberMe = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');

    if (_testAccounts.containsKey(cleanPhone)) {
      final account = _testAccounts[cleanPhone]!;
      if (account['password'] == password) {
        final mockUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        _storage.write('mock_user_id', mockUserId);
        _storage.write('user_id', mockUserId);
        _storage.write('user_role', account['role']);
        _storage.write('user_name', account['name']);
        _storage.write('user_email', account['email']);
        _storage.write('user_phone', '+226$cleanPhone');
        _storage.write('user_rating', account['rating']);
        _storage.write('total_rides', account['totalRides']);
        _storage.write('loyalty_points', account['loyaltyPoints']);
        _storage.write('wallet_balance', account['walletBalance']);
        _storage.write('unread_notifications', account['unreadNotifications']);
        _storage.write('member_since', 'Jan. 2024');
        if (rememberMe) _storage.write('remember_me', true);
        return true;
      }
    }

    return false;
  }

  // --- Registration ---
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');

    if (_testAccounts.containsKey(cleanPhone)) return false;

    final mockUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _storage.write('mock_user_id', mockUserId);
    _storage.write('user_id', mockUserId);
    _storage.write('user_role', role);
    _storage.write('user_name', name);
    _storage.write('user_email', '');
    _storage.write('user_phone', '+226$cleanPhone');
    _storage.write('user_rating', 5.0);
    _storage.write('total_rides', 0);
    _storage.write('loyalty_points', 0);
    _storage.write('wallet_balance', 0.0);
    _storage.write('unread_notifications', 0);
    _storage.write('member_since', _monthYear(DateTime.now()));
    return true;
  }

  // --- Wallet ---
  Future<void> topUpWallet(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _storage.write('wallet_balance', walletBalance + amount);
  }

  Future<bool> deductFromWallet(double amount) async {
    if (walletBalance < amount) return false;
    _storage.write('wallet_balance', walletBalance - amount);
    return true;
  }

  // --- Loyalty ---
  void addLoyaltyPoints(int points) {
    _storage.write('loyalty_points', loyaltyPoints + points);
  }

  // --- Notifications ---
  void markNotificationsRead() {
    _storage.write('unread_notifications', 0);
  }

  // --- Profile update ---
  Future<void> updateProfile({String? name, String? email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (name != null && name.isNotEmpty) _storage.write('user_name', name);
    if (email != null && email.isNotEmpty) _storage.write('user_email', email);
  }

  // --- Sign out ---
  Future<void> signOut() async {
    for (final key in [
      'mock_user_id', 'mock_user_phone', 'mock_user_data',
      'user_id', 'user_role', 'user_name', 'user_email', 'user_phone',
      'user_rating', 'total_rides', 'loyalty_points', 'wallet_balance',
      'unread_notifications', 'remember_me', 'member_since',
    ]) {
      _storage.remove(key);
    }
  }

  // --- Legacy getters (backwards compat) ---
  String? getLocalUserId() => _storage.read('user_id');
  String? getLocalUserRole() => _storage.read('user_role');
  String? getLocalUserName() => _storage.read('user_name');

  String _monthYear(DateTime d) {
    const m = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${m[d.month - 1]}. ${d.year}';
  }
}
