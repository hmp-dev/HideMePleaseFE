import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class TermsOfServicesScreen extends StatefulWidget {
  const TermsOfServicesScreen({
    super.key,
  });

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsOfServicesScreen(),
      ),
    );
  }

  @override
  State<TermsOfServicesScreen> createState() => _TermsOfServicesScreenState();
}

class _TermsOfServicesScreenState extends State<TermsOfServicesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.termOfServices.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      'App 이용약관',
                      style: fontTitle05Bold(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(color: fore5),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Text(
                          "제1장 총칙",
                          style: fontBodySm(color: fore2),
                        ),
                        const VerticalSpace(15),
                        buildParagraph(
                            '제1조 (목적) 이 약관은 주식회사 하이드미플리즈(이하 "회사"라 합니다)가 운영하는 Hide Me, Please "애플리케이션"(이하 "홈페이지"와 "애플리케이션"을 "APP"이라고 합니다)의 서비스 이용 및 제공에 관한 제반 사항의 규정을 목적으로 합니다.'),
                        buildParagraph(
                            '제2조 (용어의 정의) ① 이 약관에서 사용하는 용어의 정의는 다음과 같습니다.'),
                        buildOrderedListItem(
                            '1. "서비스"라 함은 구현되는 PC, 모바일 기기를 통하여 이용자가 이용할 수 있는 보장 분석 서비스와 회사가 제공하는 제반 서비스를 의미합니다.'),
                        buildOrderedListItem(
                            '2. "이용자"란 "APP"에 접속하여 이 약관에 따라 "APP"이 제공하는 서비스를 받는 회원 및 비회원을 말합니다.'),
                        buildOrderedListItem(
                            '3. "회원"이란 "APP"에 개인정보를 제공하여 회원등록을 한 자로서, "APP"이 제공하는 서비스를 이용하는 자를 말합니다.'),
                        buildOrderedListItem(
                            '4. "모바일 기기"란 콘텐츠를 다운로드 받거나 설치하여 사용할 수 있는 기기로서, 휴대폰, 스마트폰, 휴대정보단말기(PDA), 태블릿 등을 의미합니다.'),
                        buildOrderedListItem(
                            '5. "계정정보"란 회원의 아이디, 이메일 등 회원이 회사에 제공한 정보를 의미합니다.'),
                        buildOrderedListItem(
                            '6. "애플리케이션"이란 회사가 제공하는 서비스를 이용하기 위하여 모바일 기기를 통하여 다운로드 받거나 설치하여 사용하는 프로그램 일체를 의미합니다.'),
                      ],
                    ),
                  ),
                ],
              ),
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
}


