import 'package:intl/intl.dart';

class Utils {

}

extension FormatDate on DateTime {
  String get formatted {
    return DateFormat.yMd().add_jm().format(this);
  }
}