import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final Log instance = Log._internal();

  Log._internal() : _logger = Logger();

  final Logger _logger;

  static void configureLogger() {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void trace(Object e) => instance._logger.t(getLogMsg('$e'));

  static void debug(Object e) => instance._logger.d(getLogMsg(e.toString()));

  static void info(Object e) =>
      instance._logger.i(getLogMsg('$e'), stackTrace: StackTrace.current);

  static void warning(Object e) => instance._logger.w(getLogMsg('$e'));

  static void error(Object e) => instance._logger.e(getLogMsg('$e'));

  static void fatal(Object e) => instance._logger.f(getLogMsg('$e'));
}

String getLogMsg(String message) {
  // Define ANSI escape codes for text formatting
  const String reset = '\x1B[0m'; // Reset all attributes
  const String colorGreen = '\x1B[32m';
  const String colorLightCyan = '\x1B[94m';
  String logMessage = '';
  logMessage +=
      '$colorGreen----------------🪄️🪄️🪄️HideMePlease App Log Message----------------$reset\n';
  logMessage += '$colorLightCyan$message$reset\n';
  logMessage +=
      '$colorGreen--------------------------🔧🔧🔧🔧🔧---------------------------$reset\n';

  return logMessage;
}
