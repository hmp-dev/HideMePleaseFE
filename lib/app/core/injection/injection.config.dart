// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:mobile/app/core/network/network.dart' as _i10;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i6;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i19;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i16;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i9;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i15;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i17;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i20;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i4;
import 'package:mobile/features/home/domain/repositories/wallets_repository.dart'
    as _i8;
import 'package:mobile/features/home/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i14;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i3;
import 'package:mobile/features/home/presentation/cubit/wallets_cubit.dart'
    as _i7;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i12;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i11;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i13;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i18;

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
    gh.lazySingleton<_i3.HomeCubit>(() => _i3.HomeCubit());
    gh.lazySingleton<_i4.NetworkInfoCubit>(
        () => _i4.NetworkInfoCubit(gh<_i5.Connectivity>()));
    gh.singleton<_i6.SecureStorage>(() => const _i6.SecureStorage());
    gh.lazySingleton<_i7.WalletsCubit>(
        () => _i7.WalletsCubit(gh<_i8.WalletsRepository>()));
    gh.lazySingleton<_i9.AuthLocalDataSource>(
        () => _i9.AuthLocalDataSource(gh<_i6.SecureStorage>()));
    await gh.singletonAsync<_i10.Network>(
      () {
        final i = _i10.Network(gh<_i6.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i11.ProfileRemoteDataSource>(
        () => _i11.ProfileRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i12.ProfileRepository>(
        () => _i13.ProfileRepositoryImpl(gh<_i11.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i14.WalletsRemoteDataSource>(
        () => _i14.WalletsRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i15.AuthRemoteDataSource>(
        () => _i15.AuthRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i16.AuthRepository>(() => _i17.AuthRepositoryImpl(
          gh<_i15.AuthRemoteDataSource>(),
          gh<_i9.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i18.ProfileCubit>(
        () => _i18.ProfileCubit(gh<_i12.ProfileRepository>()));
    gh.lazySingleton<_i19.AppCubit>(
        () => _i19.AppCubit(gh<_i16.AuthRepository>()));
    gh.lazySingleton<_i20.AuthCubit>(
        () => _i20.AuthCubit(gh<_i16.AuthRepository>()));
    return this;
  }
}
