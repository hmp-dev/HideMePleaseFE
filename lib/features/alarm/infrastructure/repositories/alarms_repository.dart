// ignore_for_file: unused_field

import 'package:injectable/injectable.dart';
import 'package:mobile/features/alarm/domain/repositories/alarms_repository.dart';
import 'package:mobile/features/alarm/infrastructure/data_sources/alarms_remote_data_source.dart';

@LazySingleton(as: AlarmsRepository)
class AlarmsRepositoryImpl implements AlarmsRepository {
  final AlarmsRemoteDataSource _alarmsRemoteDataSource;

  const AlarmsRepositoryImpl(this._alarmsRemoteDataSource);
}
