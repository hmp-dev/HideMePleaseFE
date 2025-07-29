import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// This class represents the screen for displaying the privacy policy.
///
/// It extends the [StatefulWidget] class and has a single method [PrivacyPolicyScreen.createState]
/// which returns [_PrivacyPolicyScreenState].
class PrivacyPolicyScreen extends StatefulWidget {
  /// This constructor initializes [PrivacyPolicyScreen].
  ///
  /// It takes no parameters.
  const PrivacyPolicyScreen({
    super.key,
  });

  /// This method is used to navigate to the [PrivacyPolicyScreen].
  ///
  /// It takes a [BuildContext] as a parameter and returns a [Future<dynamic>].
  static Future<dynamic> push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  /// This method overrides the [StatefulWidget.createState] method of the superclass.
  ///
  /// It returns an instance of [_PrivacyPolicyScreenState].
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  void initState() {
    super.initState();
  }

  final String terms = '''
개인정보처리방침

주식회사 하이드미플리즈(이하 ‘회사’)는 「개인정보보호법」 및 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」에 따라 회사가 운영하는 Hide Me, Please 애플리케이션(이하 ‘APP’) 이용자의 개인정보 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.
회사는 개인정보처리방침의 지속적인 개선을 위하여 개정 절차를 마련하고 있으며, 본 방침은 수시로 변경될 수 있으니 정기적으로 확인하여 주시기 바랍니다.

제1조 (개인정보의 수집 및 이용목적)
① 수집 및 이용 목적
회사는 다음의 목적을 위해 개인정보를 수집하고 이용합니다.
APP 회원가입 및 서비스 이용을 위한 본인 식별
위치기반 서비스 제공 (제휴 매장 안내, 혜택 제공, 주변 사용자 연결 등)
서비스 운영 및 통계 분석을 통한 품질 개선
기타 회사의 정상적인 영업에 필요한 범위
② 수집 항목
이메일 주소
위치정보 (GPS)
③ 수집 방법
이용자가 APP 내 회원가입 또는 계정 연동 과정에서 입력
서비스 이용 시 자동으로 수집되는 위치정보

제2조 (개인정보의 보유 및 이용기간)
① 회사는 수집한 개인정보를 아래 기준에 따라 보유 및 이용합니다.
② 보유 및 이용기간
회원 탈퇴 시 또는 개인정보 수집·이용 목적이 달성된 경우 지체 없이 파기
관련 법령에 따라 보존이 필요한 경우 해당 법령에서 정한 기간 동안 보관
APP에 1년간 로그인하지 않은 경우, 정보통신망법에 따라 개인정보를 분리보관하거나 파기

제3조 (정보주체 및 법정대리인의 권리와 행사방법)
정보주체는 언제든지 자신의 개인정보에 대해 열람, 정정, 삭제, 처리정지 등의 권리를 행사할 수 있습니다.
위 권리는 전자우편 등을 통해 행사할 수 있으며, 회사는 지체 없이 조치합니다.
정당한 대리인을 통한 권리 행사는 위임장 제출로 가능합니다.

제4조 (개인정보 자동수집 장치의 설치·운영 및 거부)
회사는 쿠키 등 자동 수집 장치를 사용하지 않습니다.
(※ 필요 시 쿠키 사용 시점에 이 항목을 업데이트해야 함)

제5조 (개인정보의 파기 절차 및 방법)
① 회사는 개인정보 보유기간이 경과하거나 처리 목적이 달성된 경우, 지체 없이 해당 정보를 파기합니다.
② 파기 방법
전자적 파일: 복구할 수 없는 기술적 방법으로 영구 삭제
종이문서: 분쇄 또는 소각

제6조 (개인정보의 안전성 확보 조치)
회사는 개인정보 보호를 위해 아래와 같은 기술적·관리적 조치를 취하고 있습니다.
개인정보 접근 권한 최소화 및 접근 통제
개인정보 암호화 저장 및 전송
보안 프로그램 설치 및 점검
내부관리계획 수립 및 정기 교육 실시
접속기록 보관 및 위변조 방지 조치

제7조 (정보주체의 권익침해에 대한 구제방법)
정보주체는 아래 기관을 통해 개인정보 침해에 대한 상담 및 구제를 요청할 수 있습니다.
개인정보침해신고센터: privacy.kisa.or.kr /  118
개인정보분쟁조정위원회: kopico.go.kr /  1833-6972
대검찰청 사이버범죄수사단:  02-3480-3573 / www.spo.go.kr
경찰청 사이버안전국:  182 / cyberbureau.police.go.kr

제8조 (개인정보 보호책임자)
회사는 개인정보 보호 업무를 총괄하는 책임자를 지정하여, 개인정보 보호와 관련한 민원 처리 및 피해 구제 등을 담당하고 있습니다.
개인정보 보호책임자: 유현
이메일: help@hidemeplease.xyz
정보주체는 개인정보 관련 문의, 불만처리, 피해구제 등을 개인정보 보호책임자에게 문의하실 수 있습니다. 회사는 이에 대해 신속히 답변하고 처리합니다.

제9조 (개인정보 처리방침 변경)
이 개인정보처리방침은 2019.05.01.부터 적용되며, 이후 내용 추가·삭제·수정이 있는 경우 최소 7일 전부터 APP 내 공지사항을 통해 고지합니다.

''';

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.privacyPolicyTitle.tr(),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  terms,
                  textAlign: TextAlign.start,
                  style: fontBodySm(color: fore2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
