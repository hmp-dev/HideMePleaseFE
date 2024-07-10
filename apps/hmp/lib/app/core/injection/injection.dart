import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
  getIt.registerLazySingleton(() => SnackbarService());
}
