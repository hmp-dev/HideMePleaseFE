import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/nick_name_cubit.dart';
import 'package:mobile/features/my/presentation/views/edit_my_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyEditScreen extends StatefulWidget {
  const MyEditScreen({super.key, required this.userData});

  final UserProfileEntity userData;

  static push(BuildContext context, UserProfileEntity userData) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyEditScreen(userData: userData),
      ),
    );
  }

  @override
  State<MyEditScreen> createState() => _MyEditScreenState();
}

class _MyEditScreenState extends State<MyEditScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.editMyPage.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: BlocBuilder<NickNameCubit, NickNameState>(
        bloc: getIt<NickNameCubit>(),
        builder: (context, state) {
          return MyEditView(
            userData: widget.userData,
            nickNameState: state,
          );
        },
      ),
    );
  }
}
