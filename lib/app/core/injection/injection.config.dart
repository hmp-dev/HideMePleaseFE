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
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i25;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i19;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i7;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i18;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i20;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i26;
import 'package:mobile/features/common/domain/repositories/nft_repository.dart'
    as _i10;
import 'package:mobile/features/common/infrastructure/datasources/nft_remote_data_source.dart'
    as _i9;
import 'package:mobile/features/common/infrastructure/repositories/nft_repository.dart'
    as _i11;
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart'
    as _i21;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i4;
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart'
    as _i22;
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart'
    as _i24;
import 'package:mobile/features/home/domain/repositories/wallets_repository.dart'
    as _i16;
import 'package:mobile/features/home/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i15;
import 'package:mobile/features/home/infrastructure/repositories/wallets_repository.dart'
    as _i17;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i3;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i13;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i12;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i14;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i23;

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
    gh.lazySingleton<_i15.WalletsRemoteDataSource>(
        () => _i15.WalletsRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i16.WalletsRepository>(
        () => _i17.WalletsRepositoryImpl(gh<_i15.WalletsRemoteDataSource>()));
    gh.lazySingleton<_i18.AuthRemoteDataSource>(
        () => _i18.AuthRemoteDataSource(gh<_i8.Network>()));
    gh.lazySingleton<_i19.AuthRepository>(() => _i20.AuthRepositoryImpl(
          gh<_i18.AuthRemoteDataSource>(),
          gh<_i7.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i21.EnableLocationCubit>(
        () => _i21.EnableLocationCubit(gh<_i13.ProfileRepository>()));
    gh.lazySingleton<_i22.NftCubit>(
        () => _i22.NftCubit(gh<_i10.NftRepository>()));
    gh.lazySingleton<_i23.ProfileCubit>(
        () => _i23.ProfileCubit(gh<_i13.ProfileRepository>()));
    gh.lazySingleton<_i24.WalletsCubit>(
        () => _i24.WalletsCubit(gh<_i16.WalletsRepository>()));
    gh.lazySingleton<_i25.AppCubit>(
        () => _i25.AppCubit(gh<_i19.AuthRepository>()));
    gh.lazySingleton<_i26.AuthCubit>(
        () => _i26.AuthCubit(gh<_i19.AuthRepository>()));
    return this;
  }
}
