import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile/app/core/cubit/cubit.dart';

@LazySingleton()
class NetworkInfoCubit extends Cubit<ConnectivityResult> {
  NetworkInfoCubit(Connectivity connectivityService)
      : super(ConnectivityResult.none) {
    connectivityService.onConnectivityChanged.listen((event) {
      connectionChanged(event[0]);
    });
  }

  connectionChanged(ConnectivityResult result) {
    emit(result);
  }
}

bool isConnected(ConnectivityResult connection) =>
    connection != ConnectivityResult.none;
