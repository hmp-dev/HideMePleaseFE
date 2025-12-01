import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// A widget that displays the version information of the app.
///
/// This widget uses the `BlocConsumer` widget to listen to the state changes
/// of the `SettingsCubit` and rebuilds the UI accordingly.
///
/// When the widget is tapped, it triggers the `onSendUserToAppStore` method
/// of the `SettingsCubit` to send the user to the app store.
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
        // Build the UI based on the current state of the SettingsCubit.
        return GestureDetector(
          behavior: HitTestBehavior.opaque,  // Prevent touch passthrough to logout button
          onTap: () => getIt<SettingsCubit>().onSendUserToAppStore(),
          child: Container(
            // Removed fixed height to prevent overflow into logout button area
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.transparent,
            child: Center(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the version info text.
                      Text(
                        LocaleKeys.versionInfo.tr(),
                        style: fontCompactMd(),
                      ),
                      const VerticalSpace(7),
                      // Display the latest version text.
                      Text(
                        "${LocaleKeys.latestVersion.tr()}: ${state.installedVersion}",
                        style: fontCompactXs(color: fore3),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Display the store version text.
                  // If the build number is not empty, display it along with the store version.
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
