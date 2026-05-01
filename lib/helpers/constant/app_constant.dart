import 'package:intl/intl.dart';

final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
final DateFormat timeFormatter = DateFormat('jms');

class AppConstant {
  static const String baseAPI = 'https://projectwise.onrender.com';
  static const String baseURl = '$baseAPI/api';
  static const String yyyyMMddTHHmm = "yyyy-MM-ddTHH:mm:ss'Z'";
  static const String yyyyMMdd = "yyyy-MM-dd";
  static const String ddMMyyyy = "dd-MM-yyyy";
  static const String ddMMyyHHmmS = "dd/MM/yy hh:mm a";
  static const String name = "Vrooma";
  static const String yyyyMMddHHMMs = "yyyy-MM-dd hh:mm a";
  static String truncateWithEllipsis(int cutoff, String text) {
    if (text.isEmpty) return text;
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }
}
