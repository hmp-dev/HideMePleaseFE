import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.privacyPolicyTitle.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              buildParagraph(
                  '주식회사 하이드미플리즈(이하 "회사"라 합니다)는 개인정보보호법 및 정보통신망 이용촉진 및 정보 보호 등에 관한 법률에 따라 회사가 운영하는 Hide Me, Please "애플리케이션"(이하 "애플리케이션"을 "APP"이라고 합니다) 이용자의 개인정보 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리 방침을 두고 있습니다.'),
              buildParagraph(
                  '회사는 개인정보처리방침의 지속적인 개선을 위하여 개인정보처리방침을 개정하는데 필요한 절차를 정하고 있습니다. 그리고 본 처리방침은 수시로 내용이 변경될 수 있으니 정기적으로 방문하여 확인 하시기 바랍니다.'),
              buildSubParagraph('제1조(개인정보의 수집 및 이용목적)'),
              buildSubParagraph('① 개인정보 수집 및 이용목적'),
              buildOrderedListItem(
                  '1. 본인확인에 따른 서비스 부정이용 방지, 각종 고지ㆍ통지, 고충처리, 분쟁조정을 위한 기록 보존 등을 목적으로 개인정보를 처리합니다.'),
              buildOrderedListItem(
                  '2. 앱 내 서비스 제공 및 본인인증 등을 위한 목적으로 개인정보를 처리합니다.'),
              buildOrderedListItem(
                  '3. 기타 회사의 정상적인 영업에 관계된 행위의 목적으로 개인정보를 처리합니다.'),
              buildSubParagraph('② 수집 및 이용하는 개인정보 항목'),
              buildOrderedListItem('1. 본인인증: 성명, 생년월일, 연락처'),
              buildSubParagraph('③ 수집방법'),
              buildOrderedListItem('1. "APP"에 마련된 개인정보 입력란에 본인이 직접 입력하는 방식'),
              buildOrderedSubListItem('1.1. 실명확인을 위하여 마련된 대체수단에 직접 입력하는 방식'),
              buildOrderedSubListItem(
                  '1.2. 생성정보 수집 툴을 이용한 "APP" 이용 로그 기록 자동수집'),
              buildSubParagraph('제2조(개인정보의 보유 및 이용기간)'),
              buildOrderedListItem(
                  '① 회사는 법령에 따른 개인정보 보유 이용기간 또는 정보주체로부터 개인정보를 수집시에 동의 받은 개인정보 보유, 이용 기간 내에서 개인정보를 처리• 보유합니다.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: fontBodySm(color: fore2),
      ),
    );
  }

  Widget buildSubParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: fontBodySm(color: fore2),
      ),
    );
  }

  Widget buildOrderedListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${text.split(' ')[0]} ',
            style: fontBodySm(color: fore2),
          ),
          Expanded(
            child: Text(
              text.substring(text.indexOf(' ') + 1),
              style: fontBodySm(color: fore2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderedSubListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${text.split(' ')[0]} ',
            style: fontBodySm(color: fore2),
          ),
          Expanded(
            child: Text(
              text.substring(text.indexOf(' ') + 1),
              style: fontBodySm(color: fore2),
            ),
          ),
        ],
      ),
    );
  }
}
