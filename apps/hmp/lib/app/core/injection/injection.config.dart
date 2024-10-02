// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:mobile/app/core/network/network.dart' as _i13;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i10;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i53;
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart' as _i9;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i32;
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart'
    as _i12;
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i31;
import 'package:mobile/features/auth/infrastructure/repositoriies/auth_repository.dart'
    as _i33;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i54;
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart'
    as _i4;
import 'package:mobile/features/chat/infrastrucuture/datasources/chat_remote_data_source.dart'
    as _i3;
import 'package:mobile/features/chat/infrastrucuture/repositories/chat_repository.dart'
    as _i5;
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart'
    as _i38;
import 'package:mobile/features/common/presentation/cubit/network_cubit.dart'
    as _i7;
import 'package:mobile/features/common/presentation/cubit/submit_location_cubit.dart'
    as _i27;
import 'package:mobile/features/community/presentation/cubit/community_cubit.dart'
    as _i35;
import 'package:mobile/features/community/presentation/cubit/community_details_cubit.dart'
    as _i36;
import 'package:mobile/features/community/presentation/cubit/community_rankings_cubit.dart'
    as _i37;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart' as _i6;
import 'package:mobile/features/my/domain/repositories/profile_repository.dart'
    as _i19;
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart'
    as _i18;
import 'package:mobile/features/my/infrastructure/repositories/profile_repository.dart'
    as _i20;
import 'package:mobile/features/my/presentation/cubit/member_details_cubit.dart'
    as _i39;
import 'package:mobile/features/my/presentation/cubit/membership_cubit.dart'
    as _i40;
import 'package:mobile/features/my/presentation/cubit/nick_name_cubit.dart'
    as _i45;
import 'package:mobile/features/my/presentation/cubit/points_cubit.dart'
    as _i17;
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart'
    as _i47;
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart'
    as _i15;
import 'package:mobile/features/nft/infrastructure/datasources/nft_remote_data_source.dart'
    as _i14;
import 'package:mobile/features/nft/infrastructure/repositories/nft_repository.dart'
    as _i16;
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart'
    as _i43;
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart' as _i44;
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart'
    as _i22;
import 'package:mobile/features/settings/infrastructure/data_sources/settings_remote_data_source.dart'
    as _i21;
import 'package:mobile/features/settings/infrastructure/repositries/settings_repository.dart'
    as _i23;
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart'
    as _i41;
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart'
    as _i46;
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart'
    as _i48;
import 'package:mobile/features/space/domain/repositories/space_repository.dart'
    as _i25;
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart'
    as _i24;
import 'package:mobile/features/space/infrastructure/repositories/space_repository.dart'
    as _i26;
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart'
    as _i34;
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart'
    as _i42;
import 'package:mobile/features/space/presentation/cubit/space_benefits_cubit.dart'
    as _i49;
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart'
    as _i50;
import 'package:mobile/features/space/presentation/cubit/space_detail_cubit.dart'
    as _i51;
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart'
    as _i29;
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart'
    as _i28;
import 'package:mobile/features/wallets/infrastructure/repositories/wallets_repository.dart'
    as _i30;
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart'
    as _i52;
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart' as _i11;

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
    gh.lazySingleton<_i3.ChatRemoteDataSource>(
        () => _i3.ChatRemoteDataSource());
    gh.lazySingleton<_i4.ChatRepository>(
        () => _i5.ChatRepositoryImpl(gh<_i3.ChatRemoteDataSource>()));
    gh.lazySingleton<_i6.HomeCubit>(() => _i6.HomeCubit());
    gh.lazySingleton<_i7.NetworkInfoCubit>(
        () => _i7.NetworkInfoCubit(gh<_i8.Connectivity>()));
    gh.lazySingleton<_i9.PageCubit>(() => _i9.PageCubit());
    gh.singleton<_i10.SecureStorage>(() => const _i10.SecureStorage());
    gh.lazySingleton<_i11.WepinCubit>(() => _i11.WepinCubit());
    gh.lazySingleton<_i12.AuthLocalDataSource>(
        () => _i12.AuthLocalDataSource(gh<_i10.SecureStorage>()));
    await gh.singletonAsync<_i13.Network>(
      () {
        final i = _i13.Network(gh<_i10.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i14.NftRemoteDataSource>(
        () => _i14.NftRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i15.NftRepository>(
        () => _i16.NftRepositoryImpl(gh<_i14.NftRemoteDataSource>()));
    gh.lazySingleton<_i17.PointsCubit>(
        () => _i17.PointsCubit(gh<_i15.NftRepository>()));
    gh.lazySingleton<_i18.ProfileRemoteDataSource>(
        () => _i18.ProfileRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i19.ProfileRepository>(
        () => _i20.ProfileRepositoryImpl(gh<_i18.ProfileRemoteDataSource>()));
    gh.lazySingleton<_i21.SettingsRemoteDataSource>(
        () => _i21.SettingsRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i22.SettingsRepository>(
        () => _i23.SettingsRepositoryImp(gh<_i21.SettingsRemoteDataSource>()));
    gh.lazySingleton<_i24.SpaceRemoteDataSource>(
        () => _i24.SpaceRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i25.SpaceRepository>(
        () => _i26.SpaceRepositoryImpl(gh<_i24.SpaceRemoteDataSource>()));
    gh.lazySingleton<_i27.SubmitLocationCubit>(
        () => _i27.SubmitLocationCubit(gh<_i19.ProfileRepository>()));
    gh.lazySingleton<_i28.WalletsRemoteDataSource>(
        () => _i28.WalletsRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i29.WalletsRepository>(
        () => _i30.WalletsRepositoryImpl(gh<_i28.WalletsRemoteDataSource>()));
    gh.lazySingleton<_i31.AuthRemoteDataSource>(
        () => _i31.AuthRemoteDataSource(gh<_i13.Network>()));
    gh.lazySingleton<_i32.AuthRepository>(() => _i33.AuthRepositoryImpl(
          gh<_i31.AuthRemoteDataSource>(),
          gh<_i12.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i34.BenefitRedeemCubit>(
        () => _i34.BenefitRedeemCubit(gh<_i25.SpaceRepository>()));
    gh.lazySingleton<_i35.CommunityCubit>(() => _i35.CommunityCubit(
          gh<_i15.NftRepository>(),
          gh<_i4.ChatRepository>(),
        ));
    gh.lazySingleton<_i36.CommunityDetailsCubit>(
        () => _i36.CommunityDetailsCubit(gh<_i15.NftRepository>()));
    gh.lazySingleton<_i37.CommunityRankingsCubit>(
        () => _i37.CommunityRankingsCubit(gh<_i15.NftRepository>()));
    gh.lazySingleton<_i38.EnableLocationCubit>(
        () => _i38.EnableLocationCubit(gh<_i19.ProfileRepository>()));
    gh.lazySingleton<_i39.MemberDetailsCubit>(
        () => _i39.MemberDetailsCubit(gh<_i19.ProfileRepository>()));
    gh.lazySingleton<_i40.MembershipCubit>(
        () => _i40.MembershipCubit(gh<_i15.NftRepository>()));
    gh.lazySingleton<_i41.ModelBannerCubit>(
        () => _i41.ModelBannerCubit(gh<_i22.SettingsRepository>()));
    gh.lazySingleton<_i42.NearBySpacesCubit>(
        () => _i42.NearBySpacesCubit(gh<_i25.SpaceRepository>()));
    gh.lazySingleton<_i43.NftBenefitsCubit>(
        () => _i43.NftBenefitsCubit(gh<_i15.NftRepository>()));
    gh.lazySingleton<_i44.NftCubit>(() => _i44.NftCubit(
          gh<_i15.NftRepository>(),
          gh<_i19.ProfileRepository>(),
        ));
    gh.lazySingleton<_i45.NickNameCubit>(
        () => _i45.NickNameCubit(gh<_i19.ProfileRepository>()));
    gh.lazySingleton<_i46.NotificationsCubit>(
        () => _i46.NotificationsCubit(gh<_i22.SettingsRepository>()));
    gh.lazySingleton<_i47.ProfileCubit>(() => _i47.ProfileCubit(
          gh<_i19.ProfileRepository>(),
          gh<_i4.ChatRepository>(),
        ));
    gh.lazySingleton<_i48.SettingsCubit>(
        () => _i48.SettingsCubit(gh<_i22.SettingsRepository>()));
    gh.lazySingleton<_i49.SpaceBenefitsCubit>(
        () => _i49.SpaceBenefitsCubit(gh<_i25.SpaceRepository>()));
    gh.lazySingleton<_i50.SpaceCubit>(
        () => _i50.SpaceCubit(gh<_i25.SpaceRepository>()));
    gh.lazySingleton<_i51.SpaceDetailCubit>(
        () => _i51.SpaceDetailCubit(gh<_i25.SpaceRepository>()));
    gh.lazySingleton<_i52.WalletsCubit>(
        () => _i52.WalletsCubit(gh<_i29.WalletsRepository>()));
    gh.lazySingleton<_i53.AppCubit>(
        () => _i53.AppCubit(gh<_i32.AuthRepository>()));
    gh.lazySingleton<_i54.AuthCubit>(
        () => _i54.AuthCubit(gh<_i32.AuthRepository>()));
    return this;
  }
}
