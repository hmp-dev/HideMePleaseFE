// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:mobile/app/core/network/network.dart' as _i6;
import 'package:mobile/app/core/storage/secure_storage.dart' as _i5;
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart' as _i3;
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
    gh.singleton<_i5.SecureStorage>(() => const _i5.SecureStorage());
    await gh.singletonAsync<_i6.Network>(
      () {
        final i = _i6.Network(gh<_i5.SecureStorage>());
        return i.initialize().then((_) => i);
      },
      preResolve: true,
    );
    return this;
  }
}
