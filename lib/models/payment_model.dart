import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  cash,
  mobileMoney,
  card,
  wallet,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum MobileMoneyProvider {
  orangeMoney,
  moovMoney,
  coris,
  wave,
  mtnMobileMoney,
}

class PaymentModel {
  final String id;
  final String rideId;
  final String clientId;
  final String? driverId;
  final double amount;
  final double? commission;
  final double? driverEarnings;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? mobileMoneyNumber;
  final MobileMoneyProvider? mobileMoneyProvider;
  final String? cardLast4;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? receiptUrl;

  PaymentModel({
    required this.id,
    required this.rideId,
    required this.clientId,
    this.driverId,
    required this.amount,
    this.commission,
    this.driverEarnings,
    required this.method,
    required this.status,
    this.transactionId,
    this.mobileMoneyNumber,
    this.mobileMoneyProvider,
    this.cardLast4,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.receiptUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      rideId: json['rideId'] ?? '',
      clientId: json['clientId'] ?? '',
      driverId: json['driverId'],
      amount: (json['amount'] ?? 0).toDouble(),
      commission: json['commission']?.toDouble(),
      driverEarnings: json['driverEarnings']?.toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      mobileMoneyNumber: json['mobileMoneyNumber'],
      mobileMoneyProvider: json['mobileMoneyProvider'] != null
          ? MobileMoneyProvider.values.firstWhere(
              (e) => e.toString() == 'MobileMoneyProvider.${json['mobileMoneyProvider']}',
              orElse: () => MobileMoneyProvider.orangeMoney,
            )
          : null,
      cardLast4: json['cardLast4'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt']))
          : null,
      failureReason: json['failureReason'],
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'clientId': clientId,
      'driverId': driverId,
      'amount': amount,
      'commission': commission,
      'driverEarnings': driverEarnings,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'transactionId': transactionId,
      'mobileMoneyNumber': mobileMoneyNumber,
      'mobileMoneyProvider': mobileMoneyProvider?.toString().split('.').last,
      'cardLast4': cardLast4,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'receiptUrl': receiptUrl,
    };
  }
}

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final List<WalletTransaction> transactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.transactions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((e) => WalletTransaction.fromJson(e))
              .toList()
          : [],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime timestamp;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
