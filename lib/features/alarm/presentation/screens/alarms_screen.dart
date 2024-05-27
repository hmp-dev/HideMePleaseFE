import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AlarmsScreen(),
      ),
    );
  }

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.alarm.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: const SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
          ],
        ),
      ),
    );
  }
}
