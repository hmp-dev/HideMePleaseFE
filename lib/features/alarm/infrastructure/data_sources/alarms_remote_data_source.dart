// ignore_for_file: unused_field

import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';

@lazySingleton
class AlarmsRemoteDataSource {
  final Network _network;

  AlarmsRemoteDataSource(this._network);
}
