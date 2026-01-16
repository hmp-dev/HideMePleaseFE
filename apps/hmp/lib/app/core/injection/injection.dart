import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  asExtension: true,
)
Future<void> configureDependencies() async {
  if (!getIt.isRegistered<SnackbarService>()) {
    getIt.registerLazySingleton(() => SnackbarService());
  }
  if (!getIt.isRegistered<Talker>()) {
    getIt.registerLazySingleton(() => Talker());
  }

  await getIt.init();
}
