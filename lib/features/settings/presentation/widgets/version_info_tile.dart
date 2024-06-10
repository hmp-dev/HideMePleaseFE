import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class VersionInfoTile extends StatelessWidget {
  const VersionInfoTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      bloc: getIt<SettingsCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () => getIt<SettingsCubit>().onSendUserToAppStore(),
          child: Container(
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.transparent,
            child: Center(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.versionInfo.tr(),
                        style: fontCompactMd(),
                      ),
                      const VerticalSpace(7),
                      Text(
                        "${LocaleKeys.latestVersion.tr()}: ${state.storeVersion}",
                        style: fontCompactXs(color: fore3),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    state.buildNumber.isNotEmpty
                        ? "${state.storeVersion} (${state.buildNumber})"
                        : state.storeVersion,
                    style: fontCompactSmMedium(color: hmpBlue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
