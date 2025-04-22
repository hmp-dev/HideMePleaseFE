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
import 'package:mobile/app/core/storage/secure_storage.dart' as _i7;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i47;
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart' as _i6;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i29;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i9;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i28;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i30;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i48;
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart'
    as _i32;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i4;
import 'package:mobile/features/common/presentation/cubit/submit_location_cubit.dart'
    as _i24;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i3;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i16;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i15;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i17;
import 'package:mobile/features/my/presentation/cubit/member_details_cubit.dart'
    as _i33;
import 'package:mobile/features/my/presentation/cubit/membership_cubit.dart'
    as _i34;
import 'package:mobile/features/my/presentation/cubit/nick_name_cubit.dart'
    as _i39;
import 'package:mobile/features/my/presentation/cubit/points_cubit.dart'
    as _i14;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i41;
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart'
    as _i12;
import 'package:mobile/features/nft/infrastructure/datasources/nft_remote_data_source.dart'
    as _i11;
import 'package:mobile/features/nft/infrastructure/repositories/nft_repository.dart'
    as _i13;
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart'
    as _i37;
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart' as _i38;
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart'
    as _i19;
import 'package:mobile/features/settings/infrastructure/data_sources/settings_remote_data_source.dart'
    as _i18;
import 'package:mobile/features/settings/infrastructure/repositries/settings_repository.dart'
    as _i20;
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart'
    as _i35;
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart'
    as _i40;
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart'
    as _i42;
import 'package:mobile/features/space/domain/repositories/space_repository.dart'
    as _i22;
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart'
    as _i21;
import 'package:mobile/features/space/infrastructure/repositories/space_repository.dart'
    as _i23;
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart'
    as _i31;
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart'
    as _i36;
import 'package:mobile/features/space/presentation/cubit/space_benefits_cubit.dart'
    as _i43;
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart'
    as _i44;
import 'package:mobile/features/space/presentation/cubit/space_detail_cubit.dart'
    as _i45;
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart'
    as _i26;
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i25;
import 'package:mobile/features/wallets/infrastructure/repositories/wallets_repository.dart'
    as _i27;
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart'
    as _i46;
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart' as _i8;

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
    gh.lazySingleton<_i8.WepinCubit>(
        () => _i8.WepinCubit(gh<_i7.SecureStorage>()));
    gh.lazySingleton<_i9.AuthLocalDataSource>(
        () => _i9.AuthLocalDataSource(gh<_i7.SecureStorage>()));
    await gh.singletonAsync<_i10.Network>(
      () {
        final i = _i10.Network(gh<_i7.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i11.NftRemoteDataSource>(
        () => _i11.NftRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i12.NftRepository>(
        () => _i13.NftRepositoryImpl(gh<_i11.NftRemoteDataSource>()));
    gh.lazySingleton<_i14.PointsCubit>(
        () => _i14.PointsCubit(gh<_i12.NftRepository>()));
    gh.lazySingleton<_i15.ProfileRemoteDataSource>(
        () => _i15.ProfileRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i16.ProfileRepository>(
        () => _i17.ProfileRepositoryImpl(gh<_i15.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i18.SettingsRemoteDataSource>(
        () => _i18.SettingsRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i19.SettingsRepository>(
        () => _i20.SettingsRepositoryImp(gh<_i18.SettingsRemoteDataSource>()));
    gh.lazySingleton<_i21.SpaceRemoteDataSource>(
        () => _i21.SpaceRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i22.SpaceRepository>(
        () => _i23.SpaceRepositoryImpl(gh<_i21.SpaceRemoteDataSource>()));
    gh.lazySingleton<_i24.SubmitLocationCubit>(
        () => _i24.SubmitLocationCubit(gh<_i16.ProfileRepository>()));
    gh.lazySingleton<_i25.WalletsRemoteDataSource>(
        () => _i25.WalletsRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i26.WalletsRepository>(
        () => _i27.WalletsRepositoryImpl(gh<_i25.WalletsRemoteDataSource>()));
    gh.lazySingleton<_i28.AuthRemoteDataSource>(
        () => _i28.AuthRemoteDataSource(gh<_i10.Network>()));
    gh.lazySingleton<_i29.AuthRepository>(() => _i30.AuthRepositoryImpl(
          gh<_i28.AuthRemoteDataSource>(),
          gh<_i9.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i31.BenefitRedeemCubit>(
        () => _i31.BenefitRedeemCubit(gh<_i22.SpaceRepository>()));
    gh.lazySingleton<_i32.EnableLocationCubit>(
        () => _i32.EnableLocationCubit(gh<_i16.ProfileRepository>()));
    gh.lazySingleton<_i33.MemberDetailsCubit>(
        () => _i33.MemberDetailsCubit(gh<_i16.ProfileRepository>()));
    gh.lazySingleton<_i34.MembershipCubit>(
        () => _i34.MembershipCubit(gh<_i12.NftRepository>()));
    gh.lazySingleton<_i35.ModelBannerCubit>(
        () => _i35.ModelBannerCubit(gh<_i19.SettingsRepository>()));
    gh.lazySingleton<_i36.NearBySpacesCubit>(
        () => _i36.NearBySpacesCubit(gh<_i22.SpaceRepository>()));
    gh.lazySingleton<_i37.NftBenefitsCubit>(
        () => _i37.NftBenefitsCubit(gh<_i12.NftRepository>()));
    gh.lazySingleton<_i38.NftCubit>(() => _i38.NftCubit(
          gh<_i12.NftRepository>(),
          gh<_i16.ProfileRepository>(),
        ));
    gh.lazySingleton<_i39.NickNameCubit>(
        () => _i39.NickNameCubit(gh<_i16.ProfileRepository>()));
    gh.lazySingleton<_i40.NotificationsCubit>(
        () => _i40.NotificationsCubit(gh<_i19.SettingsRepository>()));
    gh.lazySingleton<_i41.ProfileCubit>(
        () => _i41.ProfileCubit(gh<_i16.ProfileRepository>()));
    gh.lazySingleton<_i42.SettingsCubit>(
        () => _i42.SettingsCubit(gh<_i19.SettingsRepository>()));
    gh.lazySingleton<_i43.SpaceBenefitsCubit>(
        () => _i43.SpaceBenefitsCubit(gh<_i22.SpaceRepository>()));
    gh.lazySingleton<_i44.SpaceCubit>(
        () => _i44.SpaceCubit(gh<_i22.SpaceRepository>()));
    gh.lazySingleton<_i45.SpaceDetailCubit>(
        () => _i45.SpaceDetailCubit(gh<_i22.SpaceRepository>()));
    gh.lazySingleton<_i46.WalletsCubit>(
        () => _i46.WalletsCubit(gh<_i26.WalletsRepository>()));
    gh.lazySingleton<_i47.AppCubit>(
        () => _i47.AppCubit(gh<_i29.AuthRepository>()));
    gh.lazySingleton<_i48.AuthCubit>(() => _i48.AuthCubit(
          gh<_i29.AuthRepository>(),
          gh<_i9.AuthLocalDataSource>(),
        ));
    return this;
  }
}
