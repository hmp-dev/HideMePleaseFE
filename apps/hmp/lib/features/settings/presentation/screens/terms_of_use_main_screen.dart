import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:mobile/features/settings/presentation/screens/terms_of_services_screen.dart';
import 'package:mobile/features/settings/presentation/widgets/feature_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// `TermsOfUseMainScreen` is a stateful widget that represents the main screen for displaying terms of use.
///
/// It allows the user to navigate to the privacy policy and terms of services screens.
class TermsOfUseMainScreen extends StatefulWidget {
  // The constructor for the `TermsOfUseMainScreen` widget.
  const TermsOfUseMainScreen({
    super.key,
  });

  /// Pushes the `TermsOfUseMainScreen` to the navigation stack.
  ///
  /// Returns a `Future` that completes with the result of the navigation.
  static Future<T?> push<T extends Object?>(BuildContext context) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsOfUseMainScreen(),
      ),
    );
  }

  @override
  State<TermsOfUseMainScreen> createState() => _TermsOfUseMainScreenState();
}

class _TermsOfUseMainScreenState extends State<TermsOfUseMainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.announcement.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeatureTile(
                    title: LocaleKeys.termOfServices.tr(),
                    onTap: () {
                      TermsOfServicesScreen.push(context);
                    },
                  ),
                  const VerticalSpace(10),
                  FeatureTile(
                    title: LocaleKeys.privacyPolicyTitle.tr(),
                    onTap: () {
                      PrivacyPolicyScreen.push(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
