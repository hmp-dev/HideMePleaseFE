// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:mobile/app/core/network/network.dart' as _i9;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i7;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i3;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i11;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i8;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i10;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i12;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i13;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i5;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.AppCubit>(() => _i3.AppCubit());
    gh.lazySingleton<_i4.HomeCubit>(() => _i4.HomeCubit());
    gh.lazySingleton<_i5.NetworkInfoCubit>(
        () => _i5.NetworkInfoCubit(gh<_i6.Connectivity>()));
    gh.singleton<_i7.SecureStorage>(() => const _i7.SecureStorage());
    gh.lazySingleton<_i8.AuthLocalDataSource>(
        () => _i8.AuthLocalDataSource(gh<_i7.SecureStorage>()));
    await gh.singletonAsync<_i9.Network>(
      () {
        final i = _i9.Network(gh<_i7.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i10.AuthRemoteDataSource>(
        () => _i10.AuthRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i11.AuthRepository>(() => _i12.AuthRepositoryImpl(
          gh<_i10.AuthRemoteDataSource>(),
          gh<_i8.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i13.AuthCubit>(
        () => _i13.AuthCubit(gh<_i11.AuthRepository>()));
    return this;
  }
}
