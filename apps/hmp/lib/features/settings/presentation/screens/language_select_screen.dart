// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/shared_preferences_keys.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/widgets/language_select_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// Widget that displays the announcement screen.
///
/// This widget is responsible for displaying the announcement screen.
/// It provides a way for users to view and navigate to the details of announcements.
class LanguageSelectScreen extends StatefulWidget {
  /// Creates a [LanguageSelectScreen] widget.
  const LanguageSelectScreen({super.key});

  /// Pushes the [LanguageSelectScreen] to the navigation stack.
  ///
  /// Takes a [BuildContext] as a parameter.
  /// Returns a [Future] that resolves to the result of the navigation.
  static Future<dynamic> push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LanguageSelectScreen(),
      ),
    );
  }

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// The framework will call this method when it inflates this widget to create
  /// a new [State] object.
  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  bool isNotificationEnabled = false;
  bool isLocationInfoEnabled = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.selectLanguage.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: BlocConsumer<SettingsCubit, SettingsState>(
        bloc: getIt<SettingsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LanguageSelectTile(
                    title: LocaleKeys.english_language.tr(),
                    isSelected: context.locale.languageCode == 'en',
                    onTap: () async {
                      context.setLocale(const Locale('en', 'US'));

                      await SharedPreferencesKeys().setLanguageType(
                          const Locale('en', 'US')); // Save preference

                      // reset all cubits
                      getIt<AppCubit>().onRefresh();
                      // Navigate to start up screen
                      Navigator.pushNamedAndRemoveUntil(
                          context, Routes.startUpScreen, (route) => false);
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LanguageSelectTile(
                    title: LocaleKeys.korean_language.tr(),
                    isSelected: context.locale.languageCode == 'ko',
                    onTap: () async {
                      context.setLocale(const Locale('ko', 'KR'));

                      await SharedPreferencesKeys().setLanguageType(
                          const Locale('ko', 'KR')); // Save preference

                      // reset all cubits
                      getIt<AppCubit>().onRefresh();
                      // Navigate to start up screen
                      Navigator.pushNamedAndRemoveUntil(
                          context, Routes.startUpScreen, (route) => false);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
