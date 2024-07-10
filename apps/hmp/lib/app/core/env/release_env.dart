import 'package:envied/envied.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/env/app_env_fields.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env.release')
final class ReleaseEnv implements AppEnv, AppEnvFields {
  ReleaseEnv();

  @override
  @EnviedField(varName: 'API_URL', obfuscate: true)
  final String apiUrl = _Env.apiUrl;
}
