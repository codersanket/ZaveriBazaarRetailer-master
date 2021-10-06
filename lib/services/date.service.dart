import 'package:intl/intl.dart';

class DateService {
  static String ddMMMyyyy(String mysqlTimestamp) {
    return DateFormat('dd MMM yyyy').format(
      DateFormat('yyyy-MM-dd hh:mm:ss').parse(mysqlTimestamp),
    );
  }
  
  // ignore: non_constant_identifier_names
  static String MMMyyyy(String mysqlTimestamp) {
    if (mysqlTimestamp == null) return null;

    return DateFormat('MMM, yyyy').format(
      DateFormat('yyyy-MM-dd hh:mm:ss').parse(mysqlTimestamp),
    );
  }
}
