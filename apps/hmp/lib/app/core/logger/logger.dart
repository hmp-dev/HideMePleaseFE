import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Log {
  static final Log instance = Log._internal();

  Log._internal() : _talker = GetIt.instance<Talker>();

  final Talker _talker;

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

  static void trace(Object e) => instance._talker.verbose(getLogMsg('$e'));

  static void debug(Object e) =>
      instance._talker.debug(getLogMsg(e.toString()));

  static void info(Object e) => instance._talker.info(getLogMsg('$e'));

  static void warning(Object e) => instance._talker.warning(getLogMsg('$e'));

  static void error(Object e) => instance._talker.error(getLogMsg('$e'));

  static void fatal(Object e) => instance._talker.error(getLogMsg('$e'));
}

String getLogMsg(String message) {
  // Define ANSI escape codes for text formatting

  String logMessage = '';
  logMessage +=
      '----------------🪄️🪄️🪄️HideMePlease App Log Message----------------\n';
  logMessage += '$message\n';
  logMessage +=
      '--------------------------🔧🔧🔧🔧🔧---------------------------\n';

  return logMessage;
}
