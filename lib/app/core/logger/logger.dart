// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class Log {
  static final Log instance = Log._internal();

  Log._internal() : _logger = Logger();

  final Logger _logger;

  static void configureLogger() {
    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    // };
    // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };
  }

  static void trace(Object e) => instance._logger.t(e.toString());

  static void debug(Object e) => instance._logger.d(e.toString());

  static void info(Object e) => instance._logger.i(e.toString());

  static void warning(Object e) => instance._logger.w(e.toString());

  static void error(Object e) => instance._logger.e(e.toString());

  static void fatal(Object e) => instance._logger.f(e.toString());
}
