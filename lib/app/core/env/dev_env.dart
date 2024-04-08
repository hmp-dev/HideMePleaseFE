import 'package:envied/envied.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/env/app_env_fields.dart';

part 'dev_env.g.dart';

@Envied(name: 'Env', path: '.env.dev')
final class DevEnv implements AppEnv, AppEnvFields {
  DevEnv();

  @override
  @EnviedField(varName: 'API_URL', obfuscate: true)
  final String apiUrl = _Env.apiUrl;
}
