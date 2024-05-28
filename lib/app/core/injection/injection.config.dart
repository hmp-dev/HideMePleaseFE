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
import 'package:mobile/app/core/network/network.dart' as _i8;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i6;
import 'package:mobile/features/alarm/domain/repositories/alarms_repository.dart'
    as _i22;
import 'package:mobile/features/alarm/infrastructure/data_sources/alarms_remote_data_source.dart'
    as _i21;
import 'package:mobile/features/alarm/infrastructure/repositories/alarms_repository.dart'
    as _i23;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i32;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i25;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i7;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i24;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i26;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i33;
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart'
    as _i27;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i4;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i3;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i13;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i12;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i14;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i29;
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart'
    as _i10;
import 'package:mobile/features/nft/infrastructure/datasources/nft_remote_data_source.dart'
    as _i9;
import 'package:mobile/features/nft/infrastructure/repositories/nft_repository.dart'
    as _i11;
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart' as _i28;
import 'package:mobile/features/space/domain/repositories/space_repository.dart'
    as _i16;
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart'
    as _i15;
import 'package:mobile/features/space/infrastructure/repositories/space_repository.dart'
    as _i17;
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart'
    as _i30;
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart'
    as _i19;
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i18;
import 'package:mobile/features/wallets/infrastructure/repositories/wallets_repository.dart'
    as _i20;
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart'
    as _i31;

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
    gh.lazySingleton<_i7.AuthLocalDataSource>(
        () => _i7.AuthLocalDataSource(gh<_i6.SecureStorage>()));
    await gh.singletonAsync<_i8.Network>(
      () {
        final i = _i8.Network(gh<_i6.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i9.NftRemoteDataSource>(
        () => _i9.NftRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i10.NftRepository>(
        () => _i11.NftRepositoryImpl(gh<_i9.NftRemoteDataSource>()));
    gh.lazySingleton<_i12.ProfileRemoteDataSource>(
        () => _i12.ProfileRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i13.ProfileRepository>(
        () => _i14.ProfileRepositoryImpl(gh<_i12.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i15.SpaceRemoteDataSource>(
        () => _i15.SpaceRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i16.SpaceRepository>(
        () => _i17.SpaceRepositoryImpl(gh<_i15.SpaceRemoteDataSource>()));
    gh.lazySingleton<_i18.WalletsRemoteDataSource>(
        () => _i18.WalletsRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i19.WalletsRepository>(
        () => _i20.WalletsRepositoryImpl(gh<_i18.WalletsRemoteDataSource>()));
    gh.lazySingleton<_i21.AlarmsRemoteDataSource>(
        () => _i21.AlarmsRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i22.AlarmsRepository>(
        () => _i23.AlarmsRepositoryImpl(gh<_i21.AlarmsRemoteDataSource>()));
    gh.lazySingleton<_i24.AuthRemoteDataSource>(
        () => _i24.AuthRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i25.AuthRepository>(() => _i26.AuthRepositoryImpl(
          gh<_i24.AuthRemoteDataSource>(),
          gh<_i7.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i27.EnableLocationCubit>(
        () => _i27.EnableLocationCubit(gh<_i13.ProfileRepository>()));
    gh.lazySingleton<_i28.NftCubit>(
        () => _i28.NftCubit(gh<_i10.NftRepository>()));
    gh.lazySingleton<_i29.ProfileCubit>(
        () => _i29.ProfileCubit(gh<_i13.ProfileRepository>()));
    gh.lazySingleton<_i30.SpaceCubit>(
        () => _i30.SpaceCubit(gh<_i16.SpaceRepository>()));
    gh.lazySingleton<_i31.WalletsCubit>(
        () => _i31.WalletsCubit(gh<_i19.WalletsRepository>()));
    gh.lazySingleton<_i32.AppCubit>(
        () => _i32.AppCubit(gh<_i25.AuthRepository>()));
    gh.lazySingleton<_i33.AuthCubit>(
        () => _i33.AuthCubit(gh<_i25.AuthRepository>()));
    return this;
  }
}
