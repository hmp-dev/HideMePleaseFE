import 'package:bip39/bip39.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_field.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class SolanaImportWalletView extends StatefulWidget {
  const SolanaImportWalletView({super.key});

  @override
  State<SolanaImportWalletView> createState() => _SolanaImportWalletViewState();
}

class _SolanaImportWalletViewState extends State<SolanaImportWalletView> {
  String mnemonic = "";

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '지갑 가져오기',
      isCenterTitle: true,
      backIconPath: "assets/icons/ic_close.svg",
      onBack: () {
        Navigator.pop(context);
      },
      body: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DefaultField(
              onFocus: (isFocused) {},
              hintText: '지갑 니모닉 입력',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
              ],
              isBorderType: true,
              autoFocus: true,
              onChange: (text) {
                setState(() {
                  mnemonic = text;
                });
              },
            ),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, .0, 20.0,
                MediaQuery.of(context).viewInsets.bottom + 20.0),
            child: HMPCustomButton(
              text: '계속하다',
              onPressed: () async {
                if (validateMnemonic(mnemonic)) {
                  return Navigator.pop(context, mnemonic);
                } else {
                  context.showErrorSnackBar('니모닉이 잘못되었습니다. 나중에 다시 시도 해주십시오.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
