import 'package:envied/envied.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/env/app_env_fields.dart';

part 'uat_env.g.dart';

@Envied(name: 'Env', path: '.env.uat')
final class UatEnv implements AppEnv, AppEnvFields {
  UatEnv();

  @override
  @EnviedField(varName: 'API_URL', obfuscate: true)
  final String apiUrl = _Env.apiUrl;
}
