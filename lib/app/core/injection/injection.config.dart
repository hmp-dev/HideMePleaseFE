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
import 'package:mobile/app/core/network/network.dart' as _i9;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i7;
import 'package:mobile/features/alarm/domain/repositories/alarms_repository.dart'
    as _i23;
import 'package:mobile/features/alarm/infrastructure/data_sources/alarms_remote_data_source.dart'
    as _i22;
import 'package:mobile/features/alarm/infrastructure/repositories/alarms_repository.dart'
    as _i24;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i33;
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart' as _i6;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i26;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i8;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i25;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i27;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i34;
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart'
    as _i28;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i4;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i3;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i14;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i13;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i15;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i30;
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart'
    as _i11;
import 'package:mobile/features/nft/infrastructure/datasources/nft_remote_data_source.dart'
    as _i10;
import 'package:mobile/features/nft/infrastructure/repositories/nft_repository.dart'
    as _i12;
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart' as _i29;
import 'package:mobile/features/space/domain/repositories/space_repository.dart'
    as _i17;
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart'
    as _i16;
import 'package:mobile/features/space/infrastructure/repositories/space_repository.dart'
    as _i18;
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart'
    as _i31;
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart'
    as _i20;
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i19;
import 'package:mobile/features/wallets/infrastructure/repositories/wallets_repository.dart'
    as _i21;
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart'
    as _i32;

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
    gh.lazySingleton<_i6.PageCubit>(() => _i6.PageCubit());
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
    gh.lazySingleton<_i10.NftRemoteDataSource>(
        () => _i10.NftRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i11.NftRepository>(
        () => _i12.NftRepositoryImpl(gh<_i10.NftRemoteDataSource>()));
    gh.lazySingleton<_i13.ProfileRemoteDataSource>(
        () => _i13.ProfileRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i14.ProfileRepository>(
        () => _i15.ProfileRepositoryImpl(gh<_i13.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i16.SpaceRemoteDataSource>(
        () => _i16.SpaceRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i17.SpaceRepository>(
        () => _i18.SpaceRepositoryImpl(gh<_i16.SpaceRemoteDataSource>()));
    gh.lazySingleton<_i19.WalletsRemoteDataSource>(
        () => _i19.WalletsRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i20.WalletsRepository>(
        () => _i21.WalletsRepositoryImpl(gh<_i19.WalletsRemoteDataSource>()));
    gh.lazySingleton<_i22.AlarmsRemoteDataSource>(
        () => _i22.AlarmsRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i23.AlarmsRepository>(
        () => _i24.AlarmsRepositoryImpl(gh<_i22.AlarmsRemoteDataSource>()));
    gh.lazySingleton<_i25.AuthRemoteDataSource>(
        () => _i25.AuthRemoteDataSource(gh<_i9.Network>()));
    gh.lazySingleton<_i26.AuthRepository>(() => _i27.AuthRepositoryImpl(
          gh<_i25.AuthRemoteDataSource>(),
          gh<_i8.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i28.EnableLocationCubit>(
        () => _i28.EnableLocationCubit(gh<_i14.ProfileRepository>()));
    gh.lazySingleton<_i29.NftCubit>(
        () => _i29.NftCubit(gh<_i11.NftRepository>()));
    gh.lazySingleton<_i30.ProfileCubit>(
        () => _i30.ProfileCubit(gh<_i14.ProfileRepository>()));
    gh.lazySingleton<_i31.SpaceCubit>(
        () => _i31.SpaceCubit(gh<_i17.SpaceRepository>()));
    gh.lazySingleton<_i32.WalletsCubit>(
        () => _i32.WalletsCubit(gh<_i20.WalletsRepository>()));
    gh.lazySingleton<_i33.AppCubit>(
        () => _i33.AppCubit(gh<_i26.AuthRepository>()));
    gh.lazySingleton<_i34.AuthCubit>(
        () => _i34.AuthCubit(gh<_i26.AuthRepository>()));
    return this;
  }
}
