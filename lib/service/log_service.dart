

import 'package:logger/logger.dart';

class LogService {
  static final Logger _logger = Logger(
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(),
  );

  // success
  static void d(String message) {
    _logger.d(message);
  }

  // info
  static void i(String message) {
    _logger.i(message);
  }

  // warning
  static void w(String message) {
    _logger.w(message);
  }

  // error
  static void e(String message) {
    _logger.e(message);
  }
}
